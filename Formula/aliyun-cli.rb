class AliyunCli < Formula
  desc "Universal Command-Line Interface for Alibaba Cloud"
  homepage "https://github.com/aliyun/aliyun-cli"
  url "https://github.com/aliyun/aliyun-cli/archive/v3.0.48.tar.gz"
  sha256 "5e1a572eeb5aa6f88c070269c766d1326b65438095fbedf97793f698783d0a5e"

  bottle do
    cellar :any_skip_relocation
    sha256 "a007089888c8c2e3664a8a92d24d6a0f9a93856b15707d60eeb8953803ea0d8e" => :catalina
    sha256 "aabafb3a2d1cd90b990669d9d51a79bf6bf61905674778ea4cfae72b77213da0" => :mojave
    sha256 "4ff3bc16041651a60a2568cfcded5fb40fbd8b8c90ba0af273e41fa41d6ba13b" => :high_sierra
    sha256 "f742e37a626d469f28fb6d3a5993b71330bede39c52f4a0cceb80fae2a49d04d" => :x86_64_linux
  end

  depends_on "go" => :build

  def install
    ENV["GO111MODULE"] = "off"
    ENV["GOPATH"] = buildpath
    ENV["PATH"] = "#{ENV["PATH"]}:#{buildpath}/bin"
    (buildpath/"src/github.com/aliyun/aliyun-cli").install buildpath.children
    cd "src/github.com/aliyun/aliyun-cli" do
      system "make", "metas"
      system "go", "build", "-o", bin/"aliyun", "-ldflags",
                            "-X 'github.com/aliyun/aliyun-cli/cli.Version=#{version}'", "main/main.go"
      prefix.install_metafiles
    end
  end

  test do
    version_out = shell_output("#{bin}/aliyun version")
    assert_match version.to_s, version_out

    help_out = shell_output("#{bin}/aliyun --help")
    assert_match "Alibaba Cloud Command Line Interface Version #{version}", help_out
    assert_match "", help_out
    assert_match "Usage:", help_out
    assert_match "aliyun <product> <operation> [--parameter1 value1 --parameter2 value2 ...]", help_out

    oss_out = shell_output("#{bin}/aliyun oss")
    assert_match "Object Storage Service", oss_out
    assert_match "aliyun oss [command] [args...] [options...]", oss_out
  end
end
