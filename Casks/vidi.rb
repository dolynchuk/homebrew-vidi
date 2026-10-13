cask "vidi" do
  version "1.6.0,79"
  sha256 "7886f727b3266d5e9812805d530cf81cc11146eed2ba0e1716b68493018e3290"

  url "https://pub-27d78e2130484b6d8cd7b966751bb826.r2.dev/releases/v#{version.csv.first}-build.#{version.csv.second}/Vidi-#{version.csv.first}-arm64.dmg"
  name "Vidi"
  desc "Records product demos from a plan your coding agent writes"
  homepage "https://vidi-cloud.vercel.app/"

  livecheck do
    url "https://pub-27d78e2130484b6d8cd7b966751bb826.r2.dev/releases/latest/latest.json"
    strategy :json do |json|
      "#{json["version"].split("+").first},#{json["build"]}"
    end
  end

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "Vidi.app"

  zap trash: [
    "~/Library/Application Support/Vidi",
    "~/Library/Preferences/com.vidi.demostudio.plist",
    "~/Library/Saved Application State/com.vidi.demostudio.savedState",
  ]

  caveats <<~EOS
    Vidi is not notarized by Apple. The first time you open it, macOS will block it:
    open System Settings > Privacy & Security and choose "Open Anyway".
  EOS
end
