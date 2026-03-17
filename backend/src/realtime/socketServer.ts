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
      async (payload: { senderUserId: string; roomId: string; body: string }) => {
        const result = await chatService.sendMessage(payload.senderUserId, payload.roomId, payload.body);
        io.to(payload.roomId).emit('chat:message', result.message);

        if (result.redFlag) {
          io.emit('control-room:red-flag', result.redFlag);
        }
      }
    );
  });

  return io;
}
