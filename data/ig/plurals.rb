{ :'ig' => { :i18n => { :plural => { :keys => [:other], :rule => lambda { |n| n = n.respond_to?(:abs) ? n.abs : ((m = n.to_s)[0] == "-" ? m[1,m.length] : m); :other } } } } }