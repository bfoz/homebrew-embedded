require "formula"

class GccArmEmbedded < Formula
  homepage 'https://launchpad.net/gcc-arm-embedded'
  url 'https://launchpad.net/gcc-arm-embedded/4.8/4.8-2013-q4-major/+download/gcc-arm-none-eabi-4_8-2013q4-20131204-src.tar.bz2'
  sha1 '7e9db2a3fe818c6fd04fae21e083c824c6c7dd12'

  onoe 'Must build with --env=std' unless build.include?('env=std')
  onoe 'Must build with --cc=gcc-4.2' unless build.include?('cc=gcc-4.2')

  depends_on 'apple-gcc42' => :build

  fails_with :clang do
    cause "gcc doesn't like to be built by llvm"
  end

  def install
    cd 'src' do
      system "find . -name '*.tar.*' | xargs -I% tar -xf %"
      system 'cd zlib-1.2.5 && patch -p1 < ../zlib-1.2.5.patch'
    end
    system './build-prerequisites.sh'
    system './build-toolchain.sh'   
  end

  test do
    system "gcc-arm-none-eabi"
  end
end
