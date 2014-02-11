require "formula"

class Stlink < Formula
  version '0'
  homepage 'https://github.com/texane/stlink'
  url 'https://github.com/texane/stlink.git'

  depends_on 'autoconf' => :build
  depends_on 'automake' => :build
  depends_on 'libusb' => :build
  depends_on 'pkg-config' => :build

  def install
    system './autogen.sh'
    system "./configure --prefix=#{prefix}"
    system 'make install'
  end

  test do
    system "st-info"
  end
end
