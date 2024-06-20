gleam run -m lustre/dev build app --minify

cp ./index.html ./priv/static/index.html
cp -r ./img ./priv/static/img

sed -i 's/app\.css/app\.min\.css/' ./priv/static/index.html
sed -i 's/app\.mjs/app\.min\.mjs/' ./priv/static/index.html
sed -i 's/\/priv\/static/\./' ./priv/static/index.html
