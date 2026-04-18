Pod::Spec.new do |s|
  s.name             = 'refresh_rate'
  s.version          = '0.1.0'
  s.summary          = 'Control display refresh rates in Flutter.'
  s.description      = <<-DESC
Cross-platform Flutter plugin to query and control display refresh rates.
Unlock high refresh rates (90Hz/120Hz/144Hz) by properly communicating
with the OS compositor — something Flutter doesn't do by default.
                       DESC
  s.homepage         = 'https://qoder.in'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Qoder' => 'dev@qoder.in' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'
  s.swift_version    = '5.0'
end
