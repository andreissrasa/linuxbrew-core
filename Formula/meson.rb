class Meson < Formula
  desc "Fast and user friendly build system"
  homepage "https://mesonbuild.com/"
  url "https://github.com/mesonbuild/meson/releases/download/0.54.3/meson-0.54.3.tar.gz"
  sha256 "f2bdf4cf0694e696b48261cdd14380fb1d0fe33d24744d8b2df0c12f33ebb662"
  head "https://github.com/mesonbuild/meson.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "3f4d275c9471b9638967459f233acc20dfbb6067cf62688b420132f93e2e1434" => :catalina
    sha256 "3f4d275c9471b9638967459f233acc20dfbb6067cf62688b420132f93e2e1434" => :mojave
    sha256 "3f4d275c9471b9638967459f233acc20dfbb6067cf62688b420132f93e2e1434" => :high_sierra
    sha256 "4c64fa176e942401d19119107fc032e0e582b0b17ff9cc9b2c409dcd756ad9bd" => :x86_64_linux
  end

  depends_on "ninja"
  depends_on "python@3.8"

  # https://github.com/mesonbuild/meson/issues/2567#issuecomment-504581379
  patch :DATA

  def install
    Language::Python.rewrite_python_shebang(Formula["python@3.8"].opt_bin/"python3")

    version = Language::Python.major_minor_version Formula["python@3.8"].bin/"python3"
    ENV["PYTHONPATH"] = lib/"python#{version}/site-packages"

    system Formula["python@3.8"].bin/"python3", *Language::Python.setup_install_args(prefix)

    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  test do
    (testpath/"helloworld.c").write <<~EOS
      main() {
        puts("hi");
        return 0;
      }
    EOS
    (testpath/"meson.build").write <<~EOS
      project('hello', 'c')
      executable('hello', 'helloworld.c')
    EOS

    mkdir testpath/"build" do
      system "#{bin}/meson", ".."
      assert_predicate testpath/"build/build.ninja", :exist?
    end
  end
end
__END__
--- meson-0.47.2.orig/mesonbuild/minstall.py
+++ meson-0.47.2/mesonbuild/minstall.py
@@ -486,8 +486,11 @@ class Installer:
                         printed_symlink_error = True
             if os.path.isfile(outname):
                 try:
-                    depfixer.fix_rpath(outname, install_rpath, final_path,
-                                       install_name_mappings, verbose=False)
+                    if install_rpath:
+                        depfixer.fix_rpath(outname, install_rpath, final_path,
+                                           install_name_mappings, verbose=False)
+                    else:
+                        print("RPATH changes at install time disabled")
                 except SystemExit as e:
                     if isinstance(e.code, int) and e.code == 0:
                         pass
