class TestFormulaGitRevision < Formula
  desc "Formula to test Action"
  homepage "https://github.com/Debian/dh-make-golang"
  url "https://github.com/Debian/dh-make-golang.git",
    tag:      "v0.8.0",
    revision: "5def67d96a402228d52ef6515e67a129f0aa3cd9"
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
