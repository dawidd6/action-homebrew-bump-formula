class TestFormulaGitRevision < Formula
  desc "Formula to test Action"
  homepage "https://github.com/Debian/dh-make-golang"
  url "https://github.com/Debian/dh-make-golang.git",
    tag:      "v0.8.1",
    revision: "727562a9ffcc653756d65e4703e1344a6c565d9c"
  license "MIT"
  head "https://github.com/Debian/dh-make-golang.git"

  def install
    (buildpath/"test").write <<~EOS
      test
    EOS

    share.install "test"
  end

  test do
    sleep 1
  end
end
