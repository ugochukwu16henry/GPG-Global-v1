import { prisma } from '../lib/prisma.js';
import { boundaryService } from './boundaryService.js';

function toRadians(value: number) {
  return (value * Math.PI) / 180;
}

function distanceMiles(lat1: number, lon1: number, lat2: number, lon2: number) {
  const earthRadiusMiles = 3958.8;
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return earthRadiusMiles * c;
}

export const gatheringService = {
  async ensureGlobalCommunity() {
    let globalPlace = await prisma.gatheringPlace.findFirst({
      where: { isGlobal: true },
      include: { groups: true },
    });

    if (!globalPlace) {
      globalPlace = await prisma.gatheringPlace.create({
        data: {
          name: 'Global Gathering Place',
          country: 'Global',
          stateOrCity: 'Global',
          isGlobal: true,
          latitude: 0,
          longitude: 0,
        },
        include: { groups: true },
      });
    }

    const existingGlobalGroup = globalPlace.groups.find((group: any) => group.level == 'GLOBAL');
    if (!existingGlobalGroup) {
      await prisma.gatheringGroup.create({
        data: {
          gatheringPlaceId: globalPlace.id,
          name: 'Global Community (Wide Porch)',
          level: 'GLOBAL',
          category: 'GENERAL',
        },
      });
    }
  },

  async suggestNearbyGatheringPlaces({
    userId,
    latitude,
    longitude,
    radiusMiles = 20,
  }: {
    userId: string;
    latitude: number;
    longitude: number;
    radiusMiles?: number;
  }) {
    const blockedIds = await boundaryService.blockedUserIdsForViewer(userId);
    const places = await prisma.gatheringPlace.findMany({
      include: {
        groups: {
          include: {
            memberships: {
              include: { user: true },
            },
          },
        },
      },
      take: 200,
    });

    return places
      .map((place: any) => ({
        ...place,
        distanceMiles: distanceMiles(latitude, longitude, place.latitude, place.longitude),
      }))
      .filter((place: any) => place.distanceMiles <= radiusMiles)
      .map((place: any) => ({
        ...place,
        groups: place.groups.map((group: any) => ({
          ...group,
          memberships: group.memberships.filter((membership: any) => !blockedIds.has(membership.userId)),
        })),
      }))
      .sort((a: any, b: any) => a.distanceMiles - b.distanceMiles);
  },

  async upsertLocalGatheringPlace({
    name,
    country,
    stateOrCity,
    lga,
    latitude,
    longitude,
  }: {
    name: string;
    country: string;
    stateOrCity: string;
    lga?: string;
    latitude: number;
    longitude: number;
  }) {
    const existing = await prisma.gatheringPlace.findFirst({
      where: {
        name,
        country,
        stateOrCity,
      },
    });

    const place = existing
      ? await prisma.gatheringPlace.update({
          where: { id: existing.id },
          data: { lga, latitude, longitude },
        })
      : await prisma.gatheringPlace.create({
          data: {
            name,
            country,
            stateOrCity,
            lga,
            latitude,
            longitude,
            isGlobal: false,
          },
        });

    const localAnchor = await prisma.gatheringGroup.findFirst({
      where: {
        gatheringPlaceId: place.id,
        level: 'LOCAL',
      },
    });

    if (!localAnchor) {
      await prisma.gatheringGroup.create({
        data: {
          gatheringPlaceId: place.id,
          name: '${place.name} (Local Anchor)',
          level: 'LOCAL',
          category: 'GENERAL',
        },
      });
    }

    return place;
  },

  async createSubGroup({
    gatheringPlaceId,
    name,
    category,
    adminUserId,
    isPrivate,
    parentGroupId,
  }: {
    gatheringPlaceId: string;
    name: string;
    category: 'GENERAL' | 'SELF_RELIANCE' | 'TEMPLE_PREP' | 'SOCIAL';
    adminUserId: string;
    isPrivate?: boolean;
    parentGroupId?: string;
  }) {
    const group = await prisma.gatheringGroup.create({
      data: {
        gatheringPlaceId,
        name,
        level: 'SUB_GROUP',
        category,
        adminUserId,
        isPrivate: isPrivate ?? false,
        parentGroupId,
      },
    });

    await prisma.gatheringGroupMembership.upsert({
      where: {
        userId_groupId: {
          userId: adminUserId,
          groupId: group.id,
        },
      },
      create: {
        userId: adminUserId,
        groupId: group.id,
        role: 'LEADER',
      },
      update: {
        role: 'LEADER',
      },
    });

    return group;
  },

  async joinGroup({
    userId,
    groupId,
    role,
  }: {
    userId: string;
    groupId: string;
    role?: 'MEMBER' | 'FRIEND' | 'SEEKER' | 'MODERATOR' | 'LEADER';
  }) {
    return prisma.gatheringGroupMembership.upsert({
      where: {
        userId_groupId: {
          userId,
          groupId,
        },
      },
      create: {
        userId,
        groupId,
        role: role ?? 'MEMBER',
      },
      update: {
        role: role ?? 'MEMBER',
      },
    });
  },

  async checkInToPlace({ userId, gatheringPlaceId }: { userId: string; gatheringPlaceId: string }) {
    await prisma.gatheringCheckIn.create({
      data: {
        userId,
        gatheringPlaceId,
      },
    });

    const place = await prisma.gatheringPlace.findUnique({ where: { id: gatheringPlaceId } });
    if (!place) {
      throw new Error('Gathering place not found.');
    }

    return {
      message:
        'Welcome to ${place.name}! Brother Chidi is the local lead here. Would you like to say hello?',
    };
  },

  async groupsForUser(userId: string) {
    const blockedIds = await boundaryService.blockedUserIdsForViewer(userId);
    const memberships = await prisma.gatheringGroupMembership.findMany({
      where: { userId },
      include: {
        group: {
          include: {
            gatheringPlace: true,
            memberships: {
              include: { user: true },
            },
          },
        },
      },
      orderBy: {
        joinedAt: 'desc',
      },
    });

    return memberships.map((membership: any) => ({
      ...membership,
      group: {
        ...membership.group,
        memberships: membership.group.memberships.filter((entry: any) => !blockedIds.has(entry.userId)),
      },
    }));
  },
};
