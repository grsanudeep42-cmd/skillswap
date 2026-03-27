const express = require('express');
const Message = require('../models/Message');
const Match = require('../models/Match');
const auth = require('../middleware/auth');

const router = express.Router();

// GET /api/chat/unread/count
router.get('/unread/count', auth, async (req, res) => {
  try {
    const count = await Message.countDocuments({
      sender: { $ne: req.user.id },
      read: false,
    });
    res.json({ count });
  } catch (err) {
    console.error('Unread count error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/chat/:matchId
router.get('/:matchId', auth, async (req, res) => {
  try {
    const match = await Match.findById(req.params.matchId);
    if (!match) {
      return res.status(404).json({ message: 'Match not found' });
    }

    const userId = req.user.id;
    if (match.requester.toString() !== userId && match.receiver.toString() !== userId) {
      return res.status(403).json({ message: 'Not authorized' });
    }

    const messages = await Message.find({ matchId: req.params.matchId })
      .populate('sender', 'name avatar')
      .sort({ createdAt: 1 });

    // Mark messages as read
    await Message.updateMany(
      {
        matchId: req.params.matchId,
        sender: { $ne: req.user.id },
        read: false,
      },
      { read: true }
    );

    res.json({ messages });
  } catch (err) {
    console.error('Chat history error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
