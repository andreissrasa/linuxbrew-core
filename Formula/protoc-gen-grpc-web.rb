require "language/node"

class ProtocGenGrpcWeb < Formula
  desc "Protoc plugin that generates code for gRPC-Web clients"
  homepage "https://github.com/grpc/grpc-web"
  url "https://github.com/grpc/grpc-web/archive/1.1.0.tar.gz"
  sha256 "a8a200bb4dbbbb0b3fe126c9f1f8276909d870fb641a83a3b722eed0c57c3d57"

  bottle do
    cellar :any
    sha256 "97b4e68ca6ccc980466325c4966e8a5b24f04ca13b11216d1ac5598035fd9671" => :catalina
    sha256 "1ecc3a9c5846b855ca44c32a4facd8862480ee614bf842710fb87441d840ac96" => :mojave
    sha256 "de02fd2cf1bc495852ba7208e4d95317633cd9bf0a5fcaf9ec567652917eb47e" => :high_sierra
    sha256 "e461eb3efcaee06109a8553d620d62353d20b55fcce223e19520110a1c8fd1bc" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "node" => :test
  depends_on "typescript" => :test
  depends_on "protobuf"

  def install
    bin.mkpath
    inreplace "javascript/net/grpc/web/Makefile", "/usr/local/bin/", "#{bin}/"
    system "make", "install-plugin"
  end

  test do
    # First use the plugin to generate the files.
    testdata = <<~EOS
      syntax = "proto3";
      package test;
      message TestCase {
        string name = 4;
      }
      message Test {
        repeated TestCase case = 1;
      }
      message TestResult {
        bool passed = 1;
      }
      service TestService {
        rpc RunTest(Test) returns (TestResult);
      }
    EOS
    (testpath/"test.proto").write testdata
    system "protoc", "test.proto", "--plugin=#{bin}/protoc-gen-grpc-web",
      "--js_out=import_style=commonjs:.",
      "--grpc-web_out=import_style=typescript,mode=grpcwebtext:."

    # Now see if we can import them.
    testts = <<~EOS
      import * as grpcWeb from 'grpc-web';
      import {TestServiceClient} from './TestServiceClientPb';
      import {Test, TestResult} from './test_pb';
    EOS
    (testpath/"test.ts").write testts
    system "npm", "install", *Language::Node.local_npm_install_args, "grpc-web", "@types/google-protobuf"
    system "tsc", "test.ts"
  end
end
