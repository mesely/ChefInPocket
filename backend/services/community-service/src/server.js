const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const dotenv = require('dotenv');
const mongoose = require('mongoose');

dotenv.config();

const app = express();
const port = process.env.PORT || 5004;

app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

const postSchema = new mongoose.Schema(
  {
    seedKey: { type: String, unique: true, sparse: true },
    author: String,
    role: String,
    title: String,
    description: String,
    recipeSlug: String,
    likes: Number,
    comments: Number,
    views: String,
    imageUrl: String
  },
  { timestamps: true }
);

const CommunityPost = mongoose.model('CommunityPost', postSchema);

const starterPosts = [
  {
    seedKey: 'community-post-1',
    author: '@nilsplates',
    role: 'Recipe',
    title: 'Creamy Lentil Bowl with crispy butter.',
    description: 'Shared a recipe with step-by-step plating tips.',
    recipeSlug: 'lentil-soup',
    likes: 248,
    comments: 34,
    views: '1.2k',
    imageUrl:
      'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=1200&q=80'
  },
  {
    seedKey: 'community-post-2',
    author: '@emircooks',
    role: 'Q&A',
    title: 'How do you keep Menemen creamy without overcooking it?',
    description: 'Community discussion around soft scrambled egg texture.',
    recipeSlug: 'menemen',
    likes: 128,
    comments: 21,
    views: '840',
    imageUrl:
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=1200&q=80'
  }
];

async function connectDatabase() {
  await mongoose.connect(process.env.MONGODB_URI, {
    dbName: process.env.DB_NAME || 'chef_in_pocket_community'
  });
}

async function seedPosts() {
  await CommunityPost.bulkWrite(
    starterPosts.map((post) => ({
      updateOne: {
        filter: { seedKey: post.seedKey },
        update: { $set: post },
        upsert: true
      }
    }))
  );

  await CommunityPost.deleteMany({
    seedKey: { $exists: false },
    title: {
      $in: starterPosts.map((post) => post.title)
    }
  });
}

app.get('/health', (_req, res) => {
  res.json({ service: 'community-service', status: 'healthy' });
});

app.get('/posts', async (_req, res) => {
  const posts = await CommunityPost.find().sort({ createdAt: -1 });
  res.json(posts);
});

app.post('/posts', async (req, res) => {
  const { author, title, description, role, imageUrl, recipeSlug } = req.body;

  if (!author || !title) {
    return res.status(400).json({ message: 'author and title are required.' });
  }

  const post = await CommunityPost.create({
    author,
    title,
    description: description || 'New community post',
    role: role || 'Recipe share',
    recipeSlug,
    likes: 0,
    comments: 0,
    views: '0',
    imageUrl:
      imageUrl ||
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=1200&q=80'
  });

  return res.status(201).json({
    message: 'Community post created.',
    post
  });
});

app.get('/profile', (_req, res) => {
  res.json({
    fullName: 'Mehmet Selman',
    username: '@selmancooks',
    savedRecipes: 24,
    publishedRecipes: 8,
    cookedMeals: 41
  });
});

async function startServer() {
  try {
    await connectDatabase();
    await seedPosts();
    app.listen(port, () => {
      console.log(`Community service is running on port ${port}`);
    });
  } catch (error) {
    console.error('Community service failed to start:', error.message);
    process.exit(1);
  }
}

startServer();
