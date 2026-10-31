class Eidolon < Formula
  desc "Report-only exact and near-duplicate media finder"
  homepage "https://github.com/AdeAnima/eidolon"
  url "https://github.com/AdeAnima/eidolon/releases/download/v0.1.0/eidolon-0.1.0.tar.gz"
  sha256 "4698c017fb4182b81bb70fca684dc833192cf4d31aff4f33e4feb195211b1614"
  license "MIT"

  bottle do
    root_url "https://github.com/AdeAnima/homebrew-tap/releases/download/eidolon-0.1.0"
    sha256 cellar: :any, arm64_sequoia: "87480d62effb1b5dbb1b1cb176f5ded9af57acf015d5fa863845bec77c9bbae5"
  end

  depends_on "llvm" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on arch: :arm64
  depends_on "ffmpeg"
  depends_on "jpeg-turbo"
  depends_on "libheif"
  depends_on :macos
  depends_on "onnxruntime"
  depends_on "opencv"

  def install
    ENV["LIBCLANG_PATH"] = formula_opt_lib("llvm")
    ENV["EIDOLON_ORT_DYLIB_PATH"] = formula_opt_lib("onnxruntime")/"libonnxruntime.dylib"
    system "cargo", "install", *std_cargo_args(path: "crates/eidolon-cli")
    prefix.install "LICENSE", "NOTICE", "THIRD_PARTY_LICENSES"
  end

  test do
    assert_path_exists prefix/"LICENSE"
    assert_path_exists prefix/"NOTICE"
    assert_path_exists prefix/"THIRD_PARTY_LICENSES"
    (testpath/"first.txt").write "eidolon exact duplicate fixture\n"
    (testpath/"second.txt").write "eidolon exact duplicate fixture\n"
    output = shell_output("#{bin}/eidolon --offline --no-cache --no-embeddings --no-keypoints #{testpath}")
    assert_match "identical to keep_hint; score 1.000; blake3: full-file BLAKE3", output
    assert_match "2 files; 1 duplicate matches; 0 variants; 1 groups; 2 grouped files\n", output
  end
end
