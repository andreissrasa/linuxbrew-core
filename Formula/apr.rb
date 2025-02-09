class Apr < Formula
  desc "Apache Portable Runtime library"
  homepage "https://apr.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=apr/apr-1.7.0.tar.bz2"
  mirror "https://archive.apache.org/dist/apr/apr-1.7.0.tar.bz2"
  sha256 "e2e148f0b2e99b8e5c6caa09f6d4fb4dd3e83f744aa72a952f94f5a14436f7ea"

  bottle do
    cellar :any
    sha256 "277c42fcf2f5ca298a14279d1325f58da89ee4ec2132b3ccca9bf8dfdc354c48" => :catalina
    sha256 "3a245185ed7280d1a19e7c639786b4c21dd0088878be8ac87ca58510eb5c9cc1" => :mojave
    sha256 "4d01f24009ea389e2c8771c5c0bc069ae09c0f5812d7fdb0d0079106c3fc0838" => :high_sierra
    sha256 "a49a1725c76754297c0f9a268423ee9a1772d23d264360504cc3401a21d2aa7e" => :sierra
    sha256 "55aa3f0c5dcb612e8c201e0ddc63ef52db99f314a14ae0aab4b6f7d6b4f365d3" => :x86_64_linux
  end

  keg_only :provided_by_macos, "Apple's CLT provides apr"

  depends_on "autoconf" => :build

  on_linux do
    depends_on "util-linux"
  end

  # Apply r1871981 which fixes a compile error on macOS 11.0.
  # Remove with the next release, along with the autoconf call & dependency.
  patch :p0 do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/7e2246542543bbd3111a4ec29f801e6e4d538f88/apr/r1871981-macos11.patch"
    sha256 "8754b8089d0eb53a7c4fd435c9a9300560b675a8ff2c32315a5e9303408447fe"
  end

  def install
    ENV["SED"] = "sed" # prevent libtool from hardcoding sed path from superenv

    # https://bz.apache.org/bugzilla/show_bug.cgi?id=57359
    # The internal libtool throws an enormous strop if we don't do...
    ENV.deparallelize

    if OS.linux? && build.bottle?
      # Prevent hardcoded /usr/bin/gcc-4.8 compiler
      ENV["CC"] = "cc"
    end

    # Needed to apply the patch.
    system "autoconf"

    # Stick it in libexec otherwise it pollutes lib with a .exp file.
    system "./configure", "--prefix=#{libexec}"
    system "make", "install"
    bin.install_symlink Dir["#{libexec}/bin/*"]
    lib.install_symlink Dir["#{libexec}/lib/*.so*"] unless OS.mac?

    rm Dir[libexec/"lib/*.la"]

    # No need for this to point to the versioned path.
    inreplace libexec/"bin/apr-1-config", libexec, opt_libexec
  end

  test do
    assert_match opt_libexec.to_s, shell_output("#{bin}/apr-1-config --prefix")
  end
end
