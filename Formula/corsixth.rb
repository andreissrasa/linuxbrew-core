class Corsixth < Formula
  desc "Open source clone of Theme Hospital"
  homepage "https://github.com/CorsixTH/CorsixTH"
  url "https://github.com/CorsixTH/CorsixTH/archive/v0.64.tar.gz"
  sha256 "12389a95de0031baec1a3fc77208d44228177f49564f1c79ae763ab4aeeafa98"
  head "https://github.com/CorsixTH/CorsixTH.git"

  bottle do
    sha256 "55125a4f568f1ba0f85b1eb4d120f5cacaea712edd83ea8f8532e88d951775f7" => :catalina
    sha256 "a45d65b39202414cba78d393293003d43617b6bd2794fdd14d127ce606bdfee2" => :mojave
    sha256 "a03e225349a6eb5511202933fb173600db098d8c93a5272daa09bd2c05f92801" => :high_sierra
  end

  depends_on "cmake" => :build
  depends_on "luarocks" => :build
  depends_on :xcode => :build if OS.mac?
  depends_on "ffmpeg"
  depends_on "freetype"
  depends_on "lua"
  depends_on "sdl2"
  depends_on "sdl2_mixer"

  resource "lpeg" do
    url "http://www.inf.puc-rio.br/~roberto/lpeg/lpeg-1.0.2.tar.gz"
    mirror "https://sources.voidlinux.org/lua-lpeg-1.0.2/lpeg-1.0.2.tar.gz"
    sha256 "48d66576051b6c78388faad09b70493093264588fcd0f258ddaab1cdd4a15ffe"
  end

  resource "luafilesystem" do
    url "https://github.com/keplerproject/luafilesystem/archive/v1_7_0_2.tar.gz"
    sha256 "23b4883aeb4fb90b2d0f338659f33a631f9df7a7e67c54115775a77d4ac3cc59"
  end

  def install
    ENV["TARGET_BUILD_DIR"] = "."
    ENV["FULL_PRODUCT_NAME"] = "CorsixTH.app"

    luapath = libexec/"vendor"
    ENV["LUA_PATH"] = "#{luapath}/share/lua/5.3/?.lua"
    ENV["LUA_CPATH"] = "#{luapath}/lib/lua/5.3/?.so"

    resources.each do |r|
      r.stage do
        system "luarocks", "build", r.name, "--tree=#{luapath}"
      end
    end

    system "cmake", ".", "-DLUA_INCLUDE_DIR=#{Formula["lua"].opt_include}/lua",
                         "-DLUA_LIBRARY=#{Formula["lua"].opt_lib}/liblua.dylib",
                         "-DLUA_PROGRAM_PATH=#{Formula["lua"].opt_bin}/lua",
                         "-DCORSIX_TH_DATADIR=#{prefix}/CorsixTH.app/Contents/Resources/",
                         *std_cmake_args
    system "make"
    cp_r %w[CorsixTH/CorsixTH.lua CorsixTH/Lua CorsixTH/Levels CorsixTH/Campaigns CorsixTH/Graphics CorsixTH/Bitmap],
         "CorsixTH/CorsixTH.app/Contents/Resources/"
    prefix.install "CorsixTH/CorsixTH.app"

    env = { :LUA_PATH => ENV["LUA_PATH"], :LUA_CPATH => ENV["LUA_CPATH"] }
    (bin/"CorsixTH").write_env_script(prefix/"CorsixTH.app/Contents/MacOS/CorsixTH", env)
  end

  test do
    app = prefix/"CorsixTH.app/Contents/MacOS/CorsixTH"
    assert_includes MachO::Tools.dylibs(app),
                    "#{Formula["lua"].opt_lib}/liblua.5.3.dylib"
  end
end
