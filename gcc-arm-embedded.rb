require "formula"

class GccArmEmbedded < Formula
  homepage 'https://launchpad.net/gcc-arm-embedded'
  version '4_8-2014q2-20140609'
  url 'https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q2-update/+download/gcc-arm-none-eabi-4_8-2014q2-20140609-src.tar.bz2'
  sha1 '152e80087d59f13aae5e8e6afa37a8aad5fca302'

  onoe 'Must build with --env=std' unless build.include?('env=std')

  depends_on 'cloog018'
  depends_on 'expat'    # Want 2.0.1, but core has 2.1.0
  depends_on 'libelf'
  depends_on 'libmpc08'
  depends_on 'mpfr2'

  def install
    inreplace 'build-common.sh', '--with-host-libstdcxx=-static-libgcc -Wl,-lstdc++', '--with-host-libstdcxx=-lstdc++'
    inreplace 'build-common.sh', 'INSTALLDIR_NATIVE=$ROOT/install-native', "INSTALLDIR_NATIVE=#{prefix}"
    inreplace 'build-common.sh', 'INSTALLDIR_NATIVE_DOC=$ROOT/install-native/share/doc/gcc-arm-none-eabi', "INSTALLDIR_NATIVE_DOC=#{doc}"
    inreplace 'build-common.sh', 'tar cf', 'tar -cf'
    inreplace 'build-common.sh', 'tar cjfh', 'tar -cjfh'
    inreplace 'build-common.sh', 'tar xf', 'tar -xf'
    inreplace 'build-common.sh', 'TAR=gnutar', 'TAR=tar'

    inreplace 'build-toolchain.sh', 'rm -rf $INSTALLDIR_NATIVE && mkdir -p $INSTALLDIR_NATIVE', ''

    inreplace 'build-toolchain.sh', 'prepend_path PATH $INSTALLDIR_NATIVE/bin', "prepend_path PATH #{prefix}/bin"
    inreplace 'build-toolchain.sh', '--prefix=$INSTALLDIR_NATIVE', "--prefix=#{prefix}"
    inreplace 'build-toolchain.sh', '--libexecdir=$INSTALLDIR_NATIVE/lib', "--libexecdir=#{libexec}"
    inreplace 'build-toolchain.sh', '--infodir=$INSTALLDIR_NATIVE_DOC/info', "--infodir=#{info}"
    inreplace 'build-toolchain.sh', '--mandir=$INSTALLDIR_NATIVE_DOC/man', "--mandir=#{man}"
    inreplace 'build-toolchain.sh', '--htmldir=$INSTALLDIR_NATIVE_DOC/html', "--htmldir=#{doc}/html"
    inreplace 'build-toolchain.sh', '--pdfdir=$INSTALLDIR_NATIVE_DOC/pdf', "--pdfdir=#{doc}/pdf"
    inreplace 'build-toolchain.sh', '--with-sysroot=$INSTALLDIR_NATIVE/arm-none-eabi', "--with-sysroot=#{prefix}/arm-none-eabi"

    inreplace 'build-toolchain.sh', 'rmdir include', ''
    inreplace 'build-toolchain.sh', 'ln -s . $INSTALLDIR_NATIVE/arm-none-eabi/usr', "ln -s . #{prefix}/arm-none-eabi/usr"
    inreplace 'build-toolchain.sh', 'plugin_dir=$($INSTALLDIR_NATIVE/bin/arm-none-eabi-gcc -print-file-name=plugin)', "plugin_dir=$(#{bin}/arm-none-eabi-gcc -print-file-name=plugin)"

    # Find the Formulas for the dependencies that GCC needs paths to
    #  These are all keg-only, so they're not linked into HOMEBREW_PREFIX, which
    #  makes them hard for configure to find on its own.
    rdeps = recursive_dependencies
    gmp, mpc, mpfr, isl, cloog, libelf = ['gmp', 'libmpc', 'mpfr', 'isl', 'cloog', 'libelf'].map do |d|
      rdeps.find {|dep| dep.name =~ /^#{d}/ }.to_formula
    end

    inreplace 'build-toolchain.sh', /--with-gmp=.*/, "--with-gmp=#{gmp.prefix}"
    inreplace 'build-toolchain.sh', /--with-mpfr=.*/, "--with-mpfr=#{mpfr.prefix}"
    inreplace 'build-toolchain.sh', /--with-mpc=.*/, "--with-mpc=#{mpc.prefix}"
    inreplace 'build-toolchain.sh', /--with-isl=.*/, "--with-isl=#{isl.prefix}"
    inreplace 'build-toolchain.sh', /--with-cloog=.*/, "--with-cloog=#{cloog.prefix}"
    inreplace 'build-toolchain.sh', /--with-libelf=.*"/, "--with-libelf=#{libelf.prefix}\""

    inreplace 'build-toolchain.sh', '$BUILDDIR_NATIVE/host-libs/usr', "#{HOMEBREW_PREFIX}"

    # binutils does not compile cleanly under clang
    inreplace 'build-toolchain.sh', '$SRCDIR/$BINUTILS/configure', '$SRCDIR/$BINUTILS/configure --disable-werror'

    # Task III-11 builds a bz2 package, but we don't want it
    inreplace 'build-toolchain.sh', /^echo Task \[III-11\].*?popd/m, ''

    # Task IV-8 is for generating a package file, which we're not doing
    inreplace 'build-toolchain.sh', /^echo Task \[IV-8\].*?popd/m, ''

    # Task V-0 generates the package file, but we don't want it
    inreplace 'build-toolchain.sh', /^echo Task \[V-0\].*?popd/m, ''

    # Task V-1 is for generating the MD5 of the package file, but we didn't make a package file
    inreplace 'build-toolchain.sh', /^echo Task \[V-1\].*?popd/m, ''

    cd 'src' do
      system 'rm build-manual.tar.bz2 cloog* expat* gmp* installation.tar.bz2 isl* libelf* mpc* mpfr* zlib*'
      system "find . -name '*.tar.*' | xargs -I% tar -xf %"
    end

    system './build-toolchain.sh --skip_manual'
  end

  test do
    system "gcc-arm-none-eabi"
  end
end
