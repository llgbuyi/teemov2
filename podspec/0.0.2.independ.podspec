
Pod::Spec.new do |s|

  s.name         = "teemov2"
  s.version      = "0.0.2"
  s.summary      = "TeemoV2 - The iOS framework that grows your app fast(iOS5 support tag)"

  s.description  = <<-DESC
                   TeemoV2 - The iOS framework that grows your app fast （此开发框架由多玩游戏负责维护，提供邮件级技术支持）
                   Teemo:Teemo, a short-legged animals, escape fast, favorite mushroom, well known as "Group fights can lose, Teemo must die!".
                   Teemo:提莫，一种短腿动物，逃跑超快，最爱蘑菇，素有“团战可以输，提莫必须死！”的美称
                   DESC

  s.homepage     = "https://github.com/duowan/teemov2"

  s.license      = "MIT"

  s.author             = { "PonyCui" => "cuis@vip.qq.com" }

  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/duowan/teemov2.git", :tag => "0.0.2" }

  s.source_files  = "TeemoFramework", "TeemoFramework/**/*.{h,m}"
  s.preserve_paths = "TeemoFramework/**/*.{php}"

  s.requires_arc = true

end
