class TestFormulaGitRevision < Formula
  desc "Formula to test Action"
  homepage "https://github.com/Debian/dh-make-golang"
  url "https://github.com/Debian/dh-make-golang.git",
    tag:      "v0.7.0",
    revision: "ba882c9bfa490f59921a3e7b514009ef05097e56"
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
