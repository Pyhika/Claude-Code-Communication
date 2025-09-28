'use client';

import React from 'react';
import Link from 'next/link';
import Image from 'next/image';
import { motion, useInView } from 'framer-motion';
import { useRef } from 'react';
import { Product } from '@/types/product';
import { formatPrice } from '@/lib/products';

interface ProductCardProps {
  product: Product;
  onAddToCart?: (product: Product) => void;
  index?: number;
}

const ProductCard: React.FC<ProductCardProps> = ({ product, onAddToCart, index = 0 }) => {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, amount: 0.3 });

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    if (onAddToCart) {
      onAddToCart(product);
    }
  };

  const cardVariants = {
    hidden: {
      opacity: 0,
      y: 50,
      scale: 0.95
    },
    visible: {
      opacity: 1,
      y: 0,
      scale: 1,
      transition: {
        duration: 0.5,
        delay: index * 0.1,
        ease: "easeOut"
      }
    }
  };

  const contentVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.05,
        delayChildren: index * 0.1 + 0.2
      }
    }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 10 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.3,
        ease: "easeOut"
      }
    }
  };

  const imageVariants = {
    hover: {
      scale: 1.1,
      transition: {
        duration: 0.3,
        ease: "easeOut"
      }
    }
  };

  const buttonVariants = {
    hover: {
      scale: 1.1,
      backgroundColor: "#d97706",
      transition: {
        duration: 0.2,
        ease: "easeOut"
      }
    },
    tap: {
      scale: 0.95,
      transition: {
        duration: 0.1
      }
    }
  };

  return (
    <Link href={`/products/${product.id}`} className="group block">
      <motion.div
        ref={ref}
        className="bg-white rounded-lg shadow-md overflow-hidden h-full"
        initial="hidden"
        animate={isInView ? "visible" : "hidden"}
        variants={cardVariants}
        whileHover={{
          y: -8,
          boxShadow: "0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)",
          transition: {
            duration: 0.3,
            ease: "easeOut"
          }
        }}
      >
        <motion.div
          className="relative aspect-square overflow-hidden bg-gray-100"
          whileHover="hover"
        >
          <motion.div
            className="absolute inset-0 flex items-center justify-center"
            variants={imageVariants}
          >
            <div className="text-gray-400 text-center">
              <motion.svg
                className="w-20 h-20 mx-auto mb-2"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                initial={{ opacity: 0, scale: 0.5 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: index * 0.1 + 0.3, duration: 0.5 }}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={1}
                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                />
              </motion.svg>
              <motion.span
                className="text-sm"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: index * 0.1 + 0.4 }}
              >
                {product.name}
              </motion.span>
            </div>
          </motion.div>
          {product.stock <= 5 && product.stock > 0 && (
            <motion.div
              className="absolute top-2 right-2 bg-orange-500 text-white text-xs px-2 py-1 rounded"
              initial={{ opacity: 0, scale: 0 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.1 + 0.5, type: "spring", stiffness: 500, damping: 25 }}
            >
              残りわずか
            </motion.div>
          )}
          {product.stock === 0 && (
            <motion.div
              className="absolute top-2 right-2 bg-red-500 text-white text-xs px-2 py-1 rounded"
              initial={{ opacity: 0, scale: 0 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.1 + 0.5, type: "spring", stiffness: 500, damping: 25 }}
            >
              在庫切れ
            </motion.div>
          )}
        </motion.div>

        <motion.div
          className="p-4"
          initial="hidden"
          animate={isInView ? "visible" : "hidden"}
          variants={contentVariants}
        >
          <motion.div className="mb-2" variants={itemVariants}>
            <motion.span
              className="inline-block text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded"
              whileHover={{ scale: 1.05 }}
            >
              {product.category}
            </motion.span>
            {product.caffeineLevel === 'none' && (
              <motion.span
                className="inline-block ml-1 text-xs text-green-600 bg-green-50 px-2 py-1 rounded"
                whileHover={{ scale: 1.05 }}
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 + 0.3 }}
              >
                ノンカフェイン
              </motion.span>
            )}
          </motion.div>

          <motion.h3
            className="font-semibold text-lg mb-2 text-gray-900 group-hover:text-amber-600 transition-colors line-clamp-1"
            variants={itemVariants}
          >
            {product.name}
          </motion.h3>

          <motion.p
            className="text-gray-600 text-sm mb-3 line-clamp-2"
            variants={itemVariants}
          >
            {product.description}
          </motion.p>

          <motion.div
            className="flex flex-wrap gap-1 mb-3"
            variants={itemVariants}
          >
            {product.flavor.slice(0, 3).map((flavor, idx) => (
              <motion.span
                key={idx}
                className="text-xs text-amber-700 bg-amber-50 px-2 py-1 rounded"
                whileHover={{ scale: 1.1 }}
                initial={{ opacity: 0, scale: 0 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{
                  delay: index * 0.1 + 0.4 + idx * 0.05,
                  type: "spring",
                  stiffness: 300,
                  damping: 20
                }}
              >
                {flavor}
              </motion.span>
            ))}
          </motion.div>

          <motion.div
            className="flex items-center justify-between"
            variants={itemVariants}
          >
            <div>
              <motion.p
                className="text-2xl font-bold text-gray-900"
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 + 0.5, duration: 0.3 }}
              >
                {formatPrice(product.price)}
              </motion.p>
              <motion.p
                className="text-xs text-gray-500"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: index * 0.1 + 0.6 }}
              >
                {product.origin}
              </motion.p>
            </div>

            {product.stock > 0 && (
              <motion.button
                onClick={handleAddToCart}
                className="bg-amber-600 text-white px-4 py-2 rounded-md transition-colors focus:outline-none focus:ring-2 focus:ring-amber-500 focus:ring-offset-2"
                aria-label={`${product.name}をカートに追加`}
                variants={buttonVariants}
                whileHover="hover"
                whileTap="tap"
                initial={{ opacity: 0, scale: 0 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{
                  delay: index * 0.1 + 0.6,
                  type: "spring",
                  stiffness: 400,
                  damping: 20
                }}
              >
                <motion.svg
                  className="w-5 h-5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                  whileHover={{ rotate: 15 }}
                  transition={{ duration: 0.2 }}
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
                  />
                </motion.svg>
              </motion.button>
            )}

            {product.stock === 0 && (
              <motion.button
                disabled
                className="bg-gray-300 text-gray-500 px-4 py-2 rounded-md cursor-not-allowed"
                aria-label="在庫切れ"
                initial={{ opacity: 0, scale: 0 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{
                  delay: index * 0.1 + 0.6,
                  type: "spring",
                  stiffness: 400,
                  damping: 20
                }}
              >
                <svg
                  className="w-5 h-5"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M6 18L18 6M6 6l12 12"
                  />
                </svg>
              </motion.button>
            )}
          </motion.div>
        </motion.div>
      </motion.div>
    </Link>
  );
};

export default ProductCard;