class TestFormulaUrl < Formula
  desc "Formula to test Action"
  homepage "https://github.com/dawidd6/actions-updater"
  url "https://github.com/dawidd6/actions-updater/archive/v0.1.12.tar.gz"
  sha256 "79e0fb876af7cd682d736de525c35f844ef9331e66eae772a2fc8f3f46873f60"
  license "MIT"

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
