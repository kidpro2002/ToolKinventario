/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  eslint: {
    ignoreDuringBuilds: true,
  },
  typescript: {
    ignoreBuildErrors: true,
  },
  images: {
    unoptimized: true,
  },
  webpack: (config, { isServer }) => {
    // Excluir explícitamente la carpeta _desktop del build
    config.module.rules.push({
      test: /[\\/]_desktop[\\/]/,
      loader: 'ignore-loader',
    });
    
    return config;
  },
};

export default nextConfig;
