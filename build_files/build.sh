#!/bin/bash

IMAGE="kde"
#!/bin/bash

mod=(
    "base.base"
    "base.kernel"
    "base.foundation"
)

case "$IMAGE" in
    kde)
        mod+=(
            "base.de"
        )
        ;;
    *)
        echo "Unknown image: $IMAGE"
        exit 1
        ;;
esac

mod+=(
    "base.final"
)

for i in "${mod[@]}"; do
    path="/ctx/${i//./\/}.sh"
    echo "::group:: ===Running ${path}==="
    bash -c "/ctx/${i//./\/}.sh"
    echo "::endgroup::"
done

find /etc/yum.repos.d/ -maxdepth 1 -type f -name '*.repo' ! -name 'fedora.repo' ! -name 'fedora-updates.repo' ! -name 'fedora-updates-testing.repo' -exec rm -f {} +
rm -rf /tmp/* || true
dnf5 clean all

