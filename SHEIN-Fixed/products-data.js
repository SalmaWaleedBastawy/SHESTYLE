/* ==========================================================================
   SHESTYLE — products-data.js
   Shared product catalog used by products.html and product-details.html
   ========================================================================== */
const PRODUCTS = [
  {
    id: 'puff-sleeve-dress',
    name: 'Puff Sleeve Dress',
    category: 'dresses',
    sections: ['women', 'just-for-you'],
    price: 29.99,
    rating: 4.5,
    reviewCount: 45,
    images: [
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Pink', hex: '#EFC7C2' },
      { name: 'Rose', hex: '#C97B72' },
      { name: 'Black', hex: '#1B1714' }
    ],
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    description: 'Cute puff sleeve dress with a square neckline. Perfect for spring & summer.',
    details: ['Square neckline', 'Short puff sleeves', 'Back zipper closure', 'Regular fit']
  },
  {
    id: 'floral-print-top',
    name: 'Floral Print Top',
    category: 'tops',
    sections: ['women', 'just-for-you', 'sale'],
    price: 19.99,
    originalPrice: 25.99,
    rating: 4.2,
    reviewCount: 31,
    images: [
      'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1503342217505-b0a15ec3261c?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Floral Pink', hex: '#EFC7C2' },
      { name: 'Floral Blue', hex: '#8FAFC9' }
    ],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Relaxed floral print top with short sleeves, perfect for layering or wearing alone.',
    details: ['Round neckline', 'Short sleeves', 'Lightweight woven fabric', 'Relaxed fit']
  },
  {
    id: 'high-waist-jeans',
    name: 'High Waist Jeans',
    category: 'jeans',
    sections: ['women'],
    price: 34.99,
    rating: 4.7,
    reviewCount: 58,
    images: [
      'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1541099649105-f69ad21f3246?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Blue', hex: '#5E7FA3' },
      { name: 'Black', hex: '#1B1714' }
    ],
    sizes: ['24', '26', '28', '30', '32'],
    description: 'High-waisted jeans with a straight leg cut and a comfortable stretch denim blend.',
    details: ['High-rise waist', 'Straight leg', 'Stretch denim', 'Five-pocket styling']
  },
  {
    id: 'ribbed-tank-top',
    name: 'Ribbed Tank Top',
    category: 'tops',
    sections: ['women', 'just-for-you'],
    price: 14.99,
    rating: 4.3,
    reviewCount: 22,
    images: [
      'https://images.unsplash.com/photo-1554568218-0f1715e72254?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1554568218-0f1715e72254?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'White', hex: '#F5F1EA' },
      { name: 'Black', hex: '#1B1714' },
      { name: 'Rose', hex: '#C97B72' }
    ],
    sizes: ['XS', 'S', 'M', 'L', 'XL'],
    description: 'Soft ribbed tank top with a fitted silhouette, ideal as a base layer or on its own.',
    details: ['Scoop neckline', 'Ribbed stretch fabric', 'Fitted silhouette', 'Machine washable']
  },
  {
    id: 'oversized-blazer',
    name: 'Oversized Blazer',
    category: 'jackets',
    sections: ['women', 'sale'],
    price: 39.99,
    originalPrice: 54.99,
    rating: 4.6,
    reviewCount: 40,
    images: [
      'https://images.unsplash.com/photo-1551232864-3f0890e580d9?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1551232864-3f0890e580d9?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Beige', hex: '#C9A66B' },
      { name: 'Black', hex: '#1B1714' }
    ],
    sizes: ['S', 'M', 'L', 'XL'],
    description: 'Structured oversized blazer that layers easily over dresses, tops, or tees.',
    details: ['Notched lapel', 'Long sleeves', 'Front button closure', 'Oversized fit']
  },
  {
    id: 'pleated-skirt',
    name: 'Pleated Skirt',
    category: 'skirts',
    sections: ['women'],
    price: 24.99,
    rating: 4.4,
    reviewCount: 27,
    images: [
      'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1583496661160-fb5886a13d14?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Black', hex: '#1B1714' },
      { name: 'Beige', hex: '#C9A66B' }
    ],
    sizes: ['XS', 'S', 'M', 'L'],
    description: 'Flowy pleated midi skirt with an elastic waistband for all-day comfort.',
    details: ['Elastic waistband', 'Pleated midi length', 'Lightweight fabric', 'Lined']
  },

  /* ---------------- MEN ---------------- */
  {
    id: 'mens-oxford-shirt',
    name: "Men's Oxford Shirt",
    category: 'shirts',
    sections: ['men'],
    price: 27.99,
    rating: 4.5,
    reviewCount: 33,
    images: [
      'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1516257984-b1b4d707412e?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'White', hex: '#F5F1EA' },
      { name: 'Blue', hex: '#5E7FA3' }
    ],
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    description: 'Classic fit Oxford shirt in soft breathable cotton, easy to dress up or down.',
    details: ['Button-down collar', 'Long sleeves', 'Chest pocket', 'Classic fit']
  },
  {
    id: 'mens-slim-chinos',
    name: "Men's Slim Chinos",
    category: 'pants',
    sections: ['men'],
    price: 32.99,
    rating: 4.4,
    reviewCount: 28,
    images: [
      'https://images.unsplash.com/photo-1602293589930-45aad59ba3ab?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1602293589930-45aad59ba3ab?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Khaki', hex: '#C9A66B' },
      { name: 'Black', hex: '#1B1714' }
    ],
    sizes: ['30', '32', '34', '36', '38'],
    description: 'Slim fit chinos with a bit of stretch for all-day comfort at work or on weekends.',
    details: ['Slim fit', 'Stretch cotton blend', 'Zip fly', 'Five-pocket styling']
  },
  {
    id: 'mens-bomber-jacket',
    name: "Men's Bomber Jacket",
    category: 'jackets',
    sections: ['men', 'sale'],
    price: 44.99,
    originalPrice: 59.99,
    rating: 4.6,
    reviewCount: 19,
    images: [
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1551028719-00167b16eac5?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Black', hex: '#1B1714' },
      { name: 'Olive', hex: '#6B7A5E' }
    ],
    sizes: ['S', 'M', 'L', 'XL'],
    description: 'Lightweight bomber jacket with ribbed cuffs and hem, layers over anything.',
    details: ['Ribbed collar, cuffs & hem', 'Zip front closure', 'Side pockets', 'Regular fit']
  },

  /* ---------------- KIDS ---------------- */
  {
    id: 'kids-graphic-tee',
    name: 'Kids Graphic Tee',
    category: 'tops',
    sections: ['kids'],
    price: 12.99,
    rating: 4.7,
    reviewCount: 21,
    images: [
      'https://images.unsplash.com/photo-1519457851160-93a375542007?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1519457851160-93a375542007?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Yellow', hex: '#E8C468' },
      { name: 'White', hex: '#F5F1EA' }
    ],
    sizes: ['2T', '3T', '4T', '5', '6'],
    description: 'Soft cotton graphic tee, made for play with easy machine-wash care.',
    details: ['Crew neckline', 'Short sleeves', '100% cotton', 'Machine washable']
  },
  {
    id: 'kids-jogger-pants',
    name: 'Kids Jogger Pants',
    category: 'pants',
    sections: ['kids'],
    price: 16.99,
    rating: 4.5,
    reviewCount: 17,
    images: [
      'https://images.unsplash.com/photo-1519457851160-93a375542007?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1519457851160-93a375542007?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Grey', hex: '#9A9490' },
      { name: 'Navy', hex: '#2E3A4E' }
    ],
    sizes: ['2T', '3T', '4T', '5', '6'],
    description: 'Comfy jogger pants with an elastic waistband, built for a full day of play.',
    details: ['Elastic waistband', 'Tapered leg', 'Soft fleece lining', 'Side pockets']
  },

  /* ---------------- ACCESSORIES ---------------- */
  {
    id: 'mini-tote-bag',
    name: 'Mini Tote Bag',
    category: 'bags',
    sections: ['accessories', 'just-for-you'],
    price: 24.99,
    rating: 4.6,
    reviewCount: 36,
    images: [
      'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Beige', hex: '#C9A66B' },
      { name: 'Black', hex: '#1B1714' }
    ],
    sizes: ['One Size'],
    description: 'Structured mini tote with short handles, fits your everyday essentials.',
    details: ['Short top handles', 'Interior slip pocket', 'Magnetic closure', 'Faux leather']
  },
  {
    id: 'leather-belt',
    name: 'Leather Belt',
    category: 'belts',
    sections: ['accessories'],
    price: 15.99,
    rating: 4.4,
    reviewCount: 14,
    images: [
      'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Brown', hex: '#7A5230' },
      { name: 'Black', hex: '#1B1714' }
    ],
    sizes: ['S', 'M', 'L'],
    description: 'Classic leather belt with a simple metal buckle, works with almost everything.',
    details: ['Genuine leather', 'Metal buckle', 'Adjustable fit', 'Versatile styling']
  },
  {
    id: 'silk-scarf',
    name: 'Silk Scarf',
    category: 'scarves',
    sections: ['accessories', 'sale'],
    price: 18.99,
    originalPrice: 24.99,
    rating: 4.3,
    reviewCount: 11,
    images: [
      'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?q=80&w=900&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?q=80&w=900&auto=format&fit=crop&flip=h'
    ],
    colors: [
      { name: 'Pink', hex: '#EFC7C2' },
      { name: 'Rose', hex: '#C97B72' }
    ],
    sizes: ['One Size'],
    description: 'Lightweight printed scarf, an easy way to finish off any outfit.',
    details: ['Soft silky finish', 'Printed pattern', 'Lightweight', 'Versatile styling']
  }
];