class Pngquant < Formula
  desc "PNG image optimizing utility"
  homepage "https://pngquant.org/"
  url "https://pngquant.org/pngquant-2.12.5-src.tar.gz"
  sha256 "3638936cf6270eeeaabcee42e10768d78e4dc07cac9310307835c1f58b140808"
  head "https://github.com/kornelski/pngquant.git"

  bottle do
    cellar :any
    rebuild 1
    sha256 "6212657919215e9f140239aa7df37b97d1b9820543e884bc4af45ef0deda523a" => :catalina
    sha256 "0c90b318acdfa38b8fb7a0bea76c5932a9c1bfb00f2a866bbd30781631876e33" => :mojave
    sha256 "da0955f28f17ef1b50dc15256f80b5742c0c940d1c6ce683990edde6fffd642a" => :high_sierra
    sha256 "b0b78bc304a4931cb4d240e047babe60a3e34c10607097d8c64d65da3bc2e160" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build
  depends_on "libpng"
  depends_on "little-cms2"

  def install
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    system "#{bin}/pngquant", test_fixtures("test.png"), "-o", "out.png"
    assert_predicate testpath/"out.png", :exist?
  end
end
