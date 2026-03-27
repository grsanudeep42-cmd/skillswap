const express = require('express');
const http = require('http');
const mongoose = require('mongoose');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');
const { Server } = require('socket.io');

dotenv.config();

const User = require('./models/User');
const Message = require('./models/Message');

const authRoutes = require('./routes/auth');
const skillsRoutes = require('./routes/skills');
const matchesRoutes = require('./routes/matches');
const exchangesRoutes = require('./routes/exchanges');
const messagesRoutes = require('./routes/messages');

const app = express();
const server = http.createServer(app);

// Socket.io setup
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// Middleware
app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  console.log("Incoming:", req.method, req.url);
  next();
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/skills', skillsRoutes);
app.use('/api/matches', matchesRoutes);
app.use('/api/exchanges', exchangesRoutes);
app.use('/api/chat', messagesRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Track online users: socketId -> userId
const onlineUsers = new Map();
// userId -> socketId
const userSockets = new Map();

// Socket.io authentication and events
io.use((socket, next) => {
  const token = socket.handshake.auth?.token;
  if (!token) {
    return next(new Error('Authentication error'));
  }
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    socket.userId = decoded.id;
    next();
  } catch (err) {
    return next(new Error('Authentication error'));
  }
});

io.on('connection', async (socket) => {
  const userId = socket.userId;
  console.log(`User connected: ${userId}`);

  // Track online status
  onlineUsers.set(socket.id, userId);
  userSockets.set(userId, socket.id);

  // Mark user online in DB
  await User.findByIdAndUpdate(userId, { isOnline: true });

  // Broadcast online status
  socket.broadcast.emit('user_online', { userId });

  // Join chat room
  socket.on('join_chat', (matchId) => {
    socket.join(`chat_${matchId}`);
    console.log(`User ${userId} joined chat ${matchId}`);
  });

  // Send message
  socket.on('send_message', async (data) => {
    try {
      const { matchId, receiverId, content } = data;
      if (!matchId || !content) return;

      // Save message to DB
      const message = await Message.create({
        matchId,
        sender: userId,
        content,
        read: false,
      });

      const populated = await Message.findById(message._id)
        .populate('sender', 'name avatar');

      // Emit to the chat room (excluding sender)
      socket.to(`chat_${matchId}`).emit('receive_message', populated);

      // Also emit to receiver directly if they're online but not in the room
      if (receiverId && userSockets.has(receiverId)) {
        const receiverSocketId = userSockets.get(receiverId);
        io.to(receiverSocketId).emit('receive_message', populated);
      }
    } catch (err) {
      console.error('Socket send_message error:', err.message);
    }
  });

  // Typing indicator
  socket.on('typing', (data) => {
    const { matchId, isTyping } = data;
    if (matchId) {
      socket.to(`chat_${matchId}`).emit('user_typing', {
        userId,
        isTyping,
        matchId,
      });
    }
  });

  // Disconnect
  socket.on('disconnect', async () => {
    console.log(`User disconnected: ${userId}`);
    onlineUsers.delete(socket.id);
    userSockets.delete(userId);

    // Mark user offline in DB
    await User.findByIdAndUpdate(userId, { isOnline: false });

    // Broadcast offline status
    socket.broadcast.emit('user_offline', { userId });
  });
});

// Connect to MongoDB and start server
const PORT = process.env.PORT || 5000;

mongoose
  .connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected');
    server.listen(PORT, '0.0.0.0', () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err.message);
    process.exit(1);
  });
