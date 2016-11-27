Pod::Spec.new do |s|
  s.name             = 'SlideOutMenu'
  s.version          = '0.1.0'
  s.summary          = 'This simple Slide Out Menu.'
  s.description      = <<-DESC
                        This simple Slide Out Menu implementation.
                      DESC
  s.homepage         = 'https://github.com/alfian0/SlideOutMenu'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alfiansyah' => 'alfian.official.mail@gmail.com' }
  s.source           = { :git => 'https://github.com/alfian0/SlideOutMenu.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'SlideOutMenu/Base/*.swift'
end