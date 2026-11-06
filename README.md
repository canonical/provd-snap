# provd snap

The first-boot wizard backend (`provd`, the gRPC daemon behind
ubuntu-desktop-init) as a provider snap for Ubuntu Core Desktop. Staged
from the resolute `provd` deb (md5-gated byte-identity with the binary
the fat base baked). Build with `./go-build` (runs snapcraft pack as the
copilot build user).

Phase A: nothing here is snap-run. The desktop variant's
gnome-initial-setup.service raw-execs /snap/provd/current/usr/libexec/
provd unconfined (see core-base-desktop's variants/desktop/static
payload); confinement (user-scope daemon + plugs + gadget wiring) is a
later phase. Base core26-desktop, like the accountsservice snap.
