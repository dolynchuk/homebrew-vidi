cask "vidi" do
  version "1.12.1,172"
  sha256 "b3132d62deaebe2734306c698187d09382708b1700097c961c60c504014bd588"

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
