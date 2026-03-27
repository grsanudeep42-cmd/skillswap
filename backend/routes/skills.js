const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');

const router = express.Router();

const CATEGORIES = [
  { name: 'Technology', skills: ['JavaScript', 'Python', 'React', 'Node.js', 'Flutter', 'Machine Learning', 'DevOps', 'SQL', 'AWS', 'Docker'] },
  { name: 'Creative', skills: ['Graphic Design', 'UI/UX Design', 'Photography', 'Video Editing', 'Illustration', 'Animation', '3D Modeling', 'Music Production'] },
  { name: 'Language', skills: ['English', 'Spanish', 'French', 'German', 'Japanese', 'Mandarin', 'Arabic', 'Hindi', 'Korean', 'Portuguese'] },
  { name: 'Business', skills: ['Marketing', 'SEO', 'Finance', 'Accounting', 'Project Management', 'Sales', 'Entrepreneurship', 'Public Speaking'] },
  { name: 'Lifestyle', skills: ['Cooking', 'Fitness', 'Yoga', 'Meditation', 'Gardening', 'Interior Design', 'Fashion', 'Nutrition'] },
  { name: 'Academic', skills: ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'History', 'Philosophy', 'Economics', 'Statistics'] },
];

// GET /api/skills/browse?search=&category=
router.get('/browse', auth, async (req, res) => {
  try {
    const { search, category } = req.query;
    const query = { _id: { $ne: req.user.id } };

    if (search) {
      const regex = new RegExp(search, 'i');
      query.$or = [
        { skillsOffered: { $elemMatch: { $regex: regex } } },
        { skillsWanted: { $elemMatch: { $regex: regex } } },
        { name: { $regex: regex } },
      ];
    }

    if (category) {
      const cat = CATEGORIES.find(c => c.name.toLowerCase() === category.toLowerCase());
      if (cat) {
        query.skillsOffered = { $elemMatch: { $in: cat.skills.map(s => new RegExp(s, 'i')) } };
      }
    }

    const users = await User.find(query).limit(50).sort({ createdAt: -1 });
    res.json({ users: users.map(u => u.toPublicJSON()) });
  } catch (err) {
    console.error('Browse skills error:', err.message);
    res.status(500).json({ message: 'Server error' });
  }
});

// GET /api/skills/categories
router.get('/categories', auth, async (req, res) => {
  try {
    res.json({ categories: CATEGORIES });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
