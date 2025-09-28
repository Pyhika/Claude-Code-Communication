'use client'

import Link from 'next/link'
import { motion, useScroll, useTransform, useSpring } from 'framer-motion'
import { useRef } from 'react'

export default function Home() {
  const containerRef = useRef(null)
  const { scrollYProgress } = useScroll({
    target: containerRef,
    offset: ["start start", "end start"]
  })

  const smoothScrollYProgress = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001
  })

  const heroY = useTransform(smoothScrollYProgress, [0, 1], [0, -100])
  const heroOpacity = useTransform(smoothScrollYProgress, [0, 0.5], [1, 0.3])

  const featuredProducts = [
    {
      id: 1,
      name: 'ダージリン ファーストフラッシュ',
      description: '春摘みの爽やかな香りが特徴的な高級ダージリン',
      price: 2800,
      image: '/images/darjeeling.jpg',
    },
    {
      id: 2,
      name: 'アールグレイ スペシャル',
      description: 'ベルガモットの香り豊かな定番紅茶',
      price: 2200,
      image: '/images/earl-grey.jpg',
    },
    {
      id: 3,
      name: 'アッサム ゴールド',
      description: 'コクのある味わいとマルチーな香りが特徴',
      price: 2500,
      image: '/images/assam.jpg',
    },
  ]

  const categories = [
    { name: 'ダージリン', slug: 'darjeeling', icon: '🌿' },
    { name: 'アールグレイ', slug: 'earl-grey', icon: '🌸' },
    { name: 'アッサム', slug: 'assam', icon: '🍂' },
    { name: 'セイロン', slug: 'ceylon', icon: '🌺' },
  ]

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
        delayChildren: 0.2
      }
    }
  }

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut"
      }
    }
  }

  const fadeInUpVariants = {
    hidden: { opacity: 0, y: 40 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.8,
        ease: "easeOut"
      }
    }
  }

  const scaleVariants = {
    hidden: { opacity: 0, scale: 0.8 },
    visible: {
      opacity: 1,
      scale: 1,
      transition: {
        duration: 0.5,
        ease: "easeOut"
      }
    }
  }

  return (
    <div ref={containerRef}>
      {/* Hero Section with Parallax */}
      <motion.section
        className="bg-gradient-to-b from-tea-50 to-white py-16 md:py-24 overflow-hidden"
        style={{ y: heroY, opacity: heroOpacity }}
      >
        <div className="container">
          <motion.div
            className="text-center max-w-3xl mx-auto"
            initial="hidden"
            animate="visible"
            variants={containerVariants}
          >
            <motion.h1
              className="text-4xl md:text-6xl font-bold text-tea-800 mb-6"
              variants={fadeInUpVariants}
            >
              心豊かなティータイムを
            </motion.h1>
            <motion.p
              className="text-lg md:text-xl text-gray-600 mb-8"
              variants={fadeInUpVariants}
            >
              世界中から厳選した最高品質の紅茶をお届けします。
              伝統と革新が融合した、特別な一杯をお楽しみください。
            </motion.p>
            <motion.div
              variants={scaleVariants}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <Link href="/products" className="btn-primary inline-block">
                商品を見る
              </Link>
            </motion.div>
          </motion.div>
        </div>
      </motion.section>

      {/* Categories Section with Stagger Animation */}
      <motion.section
        className="py-16 bg-white"
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
        variants={containerVariants}
      >
        <div className="container">
          <motion.h2
            className="text-3xl font-bold text-center text-tea-800 mb-12"
            variants={fadeInUpVariants}
          >
            紅茶カテゴリー
          </motion.h2>
          <motion.div
            className="grid grid-cols-2 md:grid-cols-4 gap-6"
            variants={containerVariants}
          >
            {categories.map((category, index) => (
              <motion.div
                key={category.slug}
                variants={itemVariants}
                custom={index}
                whileHover={{
                  scale: 1.05,
                  transition: { duration: 0.2 }
                }}
                whileTap={{ scale: 0.95 }}
              >
                <Link
                  href={`/products?category=${category.slug}`}
                  className="card p-6 text-center block"
                >
                  <motion.div
                    className="text-4xl mb-3"
                    initial={{ rotate: 0 }}
                    whileHover={{
                      rotate: [0, -10, 10, -10, 0],
                      transition: { duration: 0.5 }
                    }}
                  >
                    {category.icon}
                  </motion.div>
                  <h3 className="font-semibold text-tea-700">{category.name}</h3>
                </Link>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </motion.section>

      {/* Featured Products with Parallax Cards */}
      <motion.section
        className="py-16 bg-tea-50"
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.2 }}
      >
        <div className="container">
          <motion.h2
            className="text-3xl font-bold text-center text-tea-800 mb-12"
            variants={fadeInUpVariants}
          >
            おすすめ商品
          </motion.h2>
          <motion.div
            className="grid grid-cols-1 md:grid-cols-3 gap-8"
            variants={containerVariants}
          >
            {featuredProducts.map((product, index) => (
              <motion.div
                key={product.id}
                className="card overflow-hidden"
                variants={itemVariants}
                custom={index}
                whileHover={{
                  y: -10,
                  boxShadow: "0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)",
                  transition: { duration: 0.3 }
                }}
              >
                <motion.div
                  className="aspect-w-16 aspect-h-12 bg-tea-100"
                  whileHover={{ scale: 1.05 }}
                  transition={{ duration: 0.3 }}
                >
                  <div className="flex items-center justify-center h-48 text-tea-300">
                    <svg className="w-24 h-24" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M4 3a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V5a2 2 0 00-2-2H4zm12 12H4l4-8 3 6 2-4 3 6z" clipRule="evenodd" />
                    </svg>
                  </div>
                </motion.div>
                <div className="p-6">
                  <h3 className="text-xl font-semibold text-tea-800 mb-2">
                    {product.name}
                  </h3>
                  <p className="text-gray-600 mb-4">
                    {product.description}
                  </p>
                  <div className="flex justify-between items-center">
                    <span className="text-2xl font-bold text-tea-600">
                      ¥{product.price.toLocaleString()}
                    </span>
                    <motion.button
                      className="btn-secondary text-sm"
                      whileHover={{ scale: 1.05 }}
                      whileTap={{ scale: 0.95 }}
                    >
                      詳細を見る
                    </motion.button>
                  </div>
                </div>
              </motion.div>
            ))}
          </motion.div>
          <motion.div
            className="text-center mt-12"
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ delay: 0.4 }}
          >
            <motion.div
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="inline-block"
            >
              <Link href="/products" className="btn-secondary inline-block">
                すべての商品を見る
              </Link>
            </motion.div>
          </motion.div>
        </div>
      </motion.section>

      {/* Features Section with Reveal Animations */}
      <motion.section
        className="py-16 bg-white"
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, amount: 0.3 }}
      >
        <div className="container">
          <motion.h2
            className="text-3xl font-bold text-center text-tea-800 mb-12"
            variants={fadeInUpVariants}
          >
            茶の道の特徴
          </motion.h2>
          <motion.div
            className="grid grid-cols-1 md:grid-cols-3 gap-8"
            variants={containerVariants}
          >
            {[
              {
                icon: "M5 13l4 4L19 7",
                title: "厳選された品質",
                description: "世界各地の信頼できる農園から、最高品質の茶葉のみを厳選して仕入れています。"
              },
              {
                icon: "M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z",
                title: "新鮮な状態でお届け",
                description: "茶葉の鮮度を保つため、適切な保管管理と迅速な配送でお客様にお届けします。"
              },
              {
                icon: "M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z",
                title: "心を込めたサービス",
                description: "お客様一人ひとりのティータイムが特別なものになるよう、心を込めてサービスをご提供します。"
              }
            ].map((feature, index) => (
              <motion.div
                key={index}
                className="text-center"
                variants={itemVariants}
                custom={index}
              >
                <motion.div
                  className="w-16 h-16 bg-tea-100 rounded-full flex items-center justify-center mx-auto mb-4"
                  whileHover={{
                    scale: 1.1,
                    rotate: 360,
                    transition: { duration: 0.5 }
                  }}
                >
                  <svg className="w-8 h-8 text-tea-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d={feature.icon} />
                  </svg>
                </motion.div>
                <h3 className="text-xl font-semibold text-tea-800 mb-2">{feature.title}</h3>
                <p className="text-gray-600">{feature.description}</p>
              </motion.div>
            ))}
          </motion.div>
        </div>
      </motion.section>

      {/* CTA Section with Fade In */}
      <motion.section
        className="py-16 bg-gradient-to-r from-tea-600 to-tea-700"
        initial={{ opacity: 0 }}
        whileInView={{ opacity: 1 }}
        viewport={{ once: true }}
        transition={{ duration: 1 }}
      >
        <motion.div
          className="container text-center"
          initial="hidden"
          whileInView="visible"
          viewport={{ once: true }}
          variants={containerVariants}
        >
          <motion.h2
            className="text-3xl font-bold text-white mb-4"
            variants={fadeInUpVariants}
          >
            今すぐ始める優雅なティータイム
          </motion.h2>
          <motion.p
            className="text-tea-100 mb-8 max-w-2xl mx-auto"
            variants={fadeInUpVariants}
          >
            新規会員登録で、初回購入時に使える10%OFFクーポンをプレゼント中！
          </motion.p>
          <motion.div
            className="flex flex-col sm:flex-row gap-4 justify-center"
            variants={containerVariants}
          >
            <motion.div
              variants={itemVariants}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <Link href="/products" className="bg-white text-tea-700 px-8 py-3 rounded-lg font-medium hover:bg-tea-50 transition-colors inline-block">
                商品を探す
              </Link>
            </motion.div>
            <motion.div
              variants={itemVariants}
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
            >
              <Link href="/register" className="border-2 border-white text-white px-8 py-3 rounded-lg font-medium hover:bg-white hover:text-tea-700 transition-colors inline-block">
                会員登録
              </Link>
            </motion.div>
          </motion.div>
        </motion.div>
      </motion.section>
    </div>
  )
}