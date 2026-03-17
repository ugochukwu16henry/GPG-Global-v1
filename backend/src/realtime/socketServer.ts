import { Server as HttpServer } from 'node:http';
import { Server } from 'socket.io';
import { env } from '../config/env.js';
import { chatService } from '../services/chatService.js';

export function createSocketServer(httpServer: HttpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: env.CLIENT_ORIGIN,
      credentials: true
    }
  });

  io.on('connection', (socket) => {
    socket.on('room:join', (roomId: string) => {
      socket.join(roomId);
    });

    socket.on(
      'chat:send',
      async (payload: { senderUserId: string; roomId: string; body: string; threadId?: string }) => {
        const result = await chatService.sendMessage(payload.senderUserId, payload.roomId, payload.body, payload.threadId);
        io.to(payload.roomId).emit('chat:message', result.message);

        if (result.redFlag) {
          io.emit('control-room:red-flag', result.redFlag);
        }
      }
    );

    socket.on('chat:typing', (payload: { roomId: string; userId: string; isTyping: boolean }) => {
      socket.to(payload.roomId).emit('chat:typing', payload);
    });

    socket.on('chat:read', async (payload: { roomId: string; messageId: string; userId: string }) => {
      await chatService.markRead(payload.messageId, payload.userId);
      io.to(payload.roomId).emit('chat:read', payload);
    });

    socket.on(
      'chat:report',
      async (payload: { roomId: string; messageId: string; reporterId: string; localAdminUserId?: string }) => {
        const result = await chatService.reportMessage(payload);
        io.to(payload.roomId).emit('chat:report:status', {
          messageId: payload.messageId,
          aiHidden: result.aiHidden,
        });

        if (payload.localAdminUserId) {
          io.emit('admin:action-required', {
            targetAdminUserId: payload.localAdminUserId,
            roomId: payload.roomId,
            messageId: payload.messageId,
            decisionOptions: result.decisionOptions,
          });
        }
      }
    );
  });

  return io;
}
