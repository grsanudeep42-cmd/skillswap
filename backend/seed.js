const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const MONGO_URI = process.env.MONGO_URI || process.env.MONGODB_URI;

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  skillsOffered: [String],
  skillsWanted: [String],
  bio: String,
  location: String,
  avatar: { type: String, default: '' },
  rating: { type: Number, default: 0 },
  totalRatings: { type: Number, default: 0 },
  completedExchanges: { type: Number, default: 0 },
  isOnline: { type: Boolean, default: false },
}, { timestamps: true });

userSchema.pre('save', async function () {
  if (!this.isModified('password')) return;
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

const User = mongoose.model('User', userSchema);

const seeds = [
  {
    name: 'Anudeep G',
    email: 'anudeep@skillswap.dev',
    password: 'Demo@1234',
    location: 'Vizag, India',
    bio: 'Full-stack developer passionate about mobile and web apps.',
    skillsOffered: ['Flutter', 'App Development', 'Web Development'],
    skillsWanted: ['Communication', 'UI/UX Design', 'Digital Marketing'],
  },
  {
    name: 'B Harish',
    email: 'harish@skillswap.dev',
    password: 'Demo@1234',
    location: 'Vizag, India',
    bio: 'Frontend developer who loves React and teaching English.',
    skillsOffered: ['React', 'English', 'JavaScript'],
    skillsWanted: ['Flutter', 'App Development', 'Python'],
  },
  {
    name: 'Priya Sharma',
    email: 'priya@skillswap.dev',
    password: 'Demo@1234',
    location: 'Delhi, India',
    bio: 'Senior UX designer passionate about human-centered design.',
    skillsOffered: ['UI/UX Design', 'Figma', 'Graphic Design'],
    skillsWanted: ['Flutter', 'Web Development', 'Python'],
  },
  {
    name: 'Rahul Verma',
    email: 'rahul@skillswap.dev',
    password: 'Demo@1234',
    location: 'Bangalore, India',
    bio: 'Backend engineer with 5 years in Python/Django.',
    skillsOffered: ['Python', 'Django', 'Machine Learning'],
    skillsWanted: ['Flutter', 'App Development', 'React'],
  },
  {
    name: 'Aisha Khan',
    email: 'aisha@skillswap.dev',
    password: 'Demo@1234',
    location: 'Hyderabad, India',
    bio: 'Digital marketing strategist helping brands grow.',
    skillsOffered: ['Digital Marketing', 'SEO', 'Content Writing'],
    skillsWanted: ['Web Development', 'React', 'Flutter'],
  },
  {
    name: 'Kiran Reddy',
    email: 'kiran@skillswap.dev',
    password: 'Demo@1234',
    location: 'Chennai, India',
    bio: 'Data scientist specializing in SQL and business intelligence.',
    skillsOffered: ['Data Science', 'SQL', 'Power BI'],
    skillsWanted: ['Communication', 'App Development', 'Flutter'],
  },
  {
    name: 'Sneha Patel',
    email: 'sneha@skillswap.dev',
    password: 'Demo@1234',
    location: 'Mumbai, India',
    bio: 'English teacher and communication coach.',
    skillsOffered: ['English', 'Communication', 'Public Speaking'],
    skillsWanted: ['Python', 'Data Science', 'Web Development'],
  },
  {
    name: 'Arjun Nair',
    email: 'arjun@skillswap.dev',
    password: 'Demo@1234',
    location: 'Kochi, India',
    bio: 'DevOps engineer who loves cloud and automation.',
    skillsOffered: ['DevOps', 'AWS', 'Docker'],
    skillsWanted: ['UI/UX Design', 'Flutter', 'App Development'],
  },
];

async function seed() {
  await mongoose.connect(MONGO_URI);
  console.log('Connected to MongoDB');
  await User.deleteMany({});
  await mongoose.connection.collection('matches').deleteMany({});
  await mongoose.connection.collection('exchanges').deleteMany({});
  await mongoose.connection.collection('messages').deleteMany({});
  console.log('Cleared all collections');
  for (const u of seeds) {
    const user = new User(u);
    await user.save();
    console.log('Created: ' + u.name);
  }
  console.log('Seed complete!');
  await mongoose.disconnect();
}

seed().catch(console.error);
