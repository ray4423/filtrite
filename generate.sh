echo "::group::Init"

set -e

log () {
    echo `date +"%m/%d/%Y %H:%M:%S"` "$@"
}
cleanup() {
    rm -f filtrite >> /dev/null 2>&1
}
filtrite() {
    echo "::group::List: $1"
    log "Start generating $1"
    ./filtrite "lists/$1.txt" "dist/$1.dat" "logs/$1.log"
    echo "::endgroup::"
}

cleanup
echo "::endgroup::"

echo "::group::Build executable"
log "Building"
go build -v -o filtrite
echo "::endgroup::"

echo "::group::Other setup steps"
chmod +x filtrite
chmod +x deps/ruleset_converter
mkdir -p dist
mkdir -p logs
echo "::endgroup::"

# Default is a special case because of the download
echo "::group::List: bromite-default"
# Download default bromite filter list
wget -O lists/bromite-default.txt https://raw.githubusercontent.com/bromite/filters/master/lists.txt
log "Start generating bromite-default"
./filtrite lists/bromite-default.txt dist/bromite-default.dat logs/bromite-default.log
echo "::endgroup::"

# All other lists can be listed here
filtrite bromite-extended

echo "::group::Cleanup"
cleanup
echo "::endgroup::"
