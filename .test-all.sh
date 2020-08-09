for i in ~/Desktop/examples/**/*.rkt; do
	echo "Testing $i";
	pushd `dirname $i/`;
	racket $i;
done
echo "Testing finished"
