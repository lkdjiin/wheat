function w --description 'Display weather report'
  set d (pwd)
  cd ~/Apps/wheat/
  ruby wheat.rb
  cd $d
end
