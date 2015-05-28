if (not fs.exists('txUI')) then
  local code = http.get('https://raw.githubusercontent.com/tuogex/txUI/master/txUI.lua').readAll()
  local file = fs.open('txUI','w')
  file.write(code)
  file.close()
else
  print('A file called "txUI" already exists!')
end
