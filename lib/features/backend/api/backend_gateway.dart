import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendGateway {
  BackendGateway({
    required this.baseUrl,
    required this.userId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final String userId;
  final http.Client _client;

  Uri get _graphqlUri => Uri.parse('$baseUrl/graphql');

  Future<Map<String, dynamic>> _query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final response = await _client.post(
      _graphqlUri,
      headers: {
        'content-type': 'application/json',
        'x-user-id': userId,
      },
      body: jsonEncode({
        'query': query,
        'variables': variables ?? <String, dynamic>{},
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Backend request failed (${response.statusCode}).');
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    if (payload['errors'] != null) {
      final errors = payload['errors'] as List<dynamic>;
      throw Exception('GraphQL error: ${errors.first['message']}');
    }

    return payload['data'] as Map<String, dynamic>;
  }

  Future<List<String>> suggestMissions(String queryText) async {
    final data = await _query(
      '''
      query SuggestMissions(
        ${r'$'}query: String!
      ) {
        suggestMissions(query: ${r'$'}query) {
          missionName
        }
      }
      ''',
      variables: {'query': queryText},
    );

    final items = data['suggestMissions'] as List<dynamic>;
    return items
        .map((item) => (item as Map<String, dynamic>)['missionName'] as String)
        .toList(growable: false);
  }

  Future<String> missionPeerMatchSummary(String missionId) async {
    final data = await _query(
      '''
      query MissionPeerMatch(
        ${r'$'}missionId: String!
      ) {
        missionPeerMatch(missionId: ${r'$'}missionId) {
          summary
        }
      }
      ''',
      variables: {'missionId': missionId},
    );

    final result = data['missionPeerMatch'] as Map<String, dynamic>;
    return result['summary'] as String;
  }

  Future<String?> createMarketplaceCheckout(String userId) async {
    final data = await _query(
      '''
      mutation CreateMarketplaceCheckout(
        ${r'$'}userId: ID!
      ) {
        createMarketplaceCheckout(userId: ${r'$'}userId) {
          checkoutUrl
        }
      }
      ''',
      variables: {'userId': userId},
    );

    final result = data['createMarketplaceCheckout'] as Map<String, dynamic>;
    return result['checkoutUrl'] as String?;
  }

  Future<String?> sendChatForModeration({
    required String senderUserId,
    required String roomId,
    required String body,
  }) async {
    final data = await _query(
      '''
      mutation SendChatMessage(
        ${r'$'}senderUserId: ID!,
        ${r'$'}roomId: String!,
        ${r'$'}body: String!
      ) {
        sendChatMessage(senderUserId: ${r'$'}senderUserId, roomId: ${r'$'}roomId, body: ${r'$'}body) {
          messageId
          redFlag {
            reason
            severity
          }
        }
      }
      ''',
      variables: {
        'senderUserId': senderUserId,
        'roomId': roomId,
        'body': body,
      },
    );

    final result = data['sendChatMessage'] as Map<String, dynamic>;
    final redFlag = result['redFlag'] as Map<String, dynamic>?;
    if (redFlag == null) {
      return null;
    }
    return '${redFlag['severity']}: ${redFlag['reason']}';
  }
}
