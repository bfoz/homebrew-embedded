require "formula"

class GccArmEmbedded < Formula
  homepage 'https://launchpad.net/gcc-arm-embedded'
  version '4_8-2013q4-20131204'
  url 'https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q1-update/+download/gcc-arm-none-eabi-4_8-2014q1-20140314-src.tar.bz2'
  sha1 '121dbfbd6a4223c33508e2a6291550369bd5c3aa'

  onoe 'Must build with --env=std' unless build.include?('env=std')

  def install
    inreplace 'build-common.sh', '--with-host-libstdcxx=-static-libgcc -Wl,-lstdc++', '--with-host-libstdcxx=-lstdc++'
    inreplace 'build-common.sh', 'tar cf', 'tar -cf'
    inreplace 'build-common.sh', 'tar cjfh', 'tar -cjfh'
    inreplace 'build-common.sh', 'tar xf', 'tar -xf'
    inreplace 'build-common.sh', 'TAR=gnutar', 'TAR=tar'

    # GCC does not compile cleanly under clang
    inreplace 'build-toolchain.sh', '$SRCDIR/$BINUTILS/configure', '$SRCDIR/$BINUTILS/configure --disable-werror'

    # Task III-7 doesn't respect --skip_manual, so delete it until it's fixed
    inreplace 'build-toolchain.sh', /^if \[ "x\$is_ppa_release" != "xyes" \]; then\necho TASK \[III-7\].*?fi/m, ''

    # Task III-11 builds a bz2 package, but we don't want it
    inreplace 'build-toolchain.sh', /^echo Task \[III-11\].*?popd/m, ''

    # Task IV-8 is for generating a package file, which we're not doing
    inreplace 'build-toolchain.sh', /^echo Task \[IV-8\].*?popd/m, ''

    # Task V-0 generates the package file, but we don't want it
    inreplace 'build-toolchain.sh', /^echo Task \[V-0\].*?popd/m, ''

    # Task V-1 is for generating the MD5 of the package file, but we didn't make a package file
    inreplace 'build-toolchain.sh', /^echo Task \[V-1\].*?popd/m, ''

    cd 'src' do
      system "find . -name '*.tar.*' | xargs -I% tar -xf %"
      system 'cd zlib-1.2.5 && patch -p1 < ../zlib-1.2.5.patch'
    end
    system './build-prerequisites.sh'
    system './build-toolchain.sh --skip_manual'
  end

  test do
    system "gcc-arm-none-eabi"
  end
end
