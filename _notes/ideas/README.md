# Potential idea collections
- Mapping APIs : Create webpage with map with multiple vehicles travelling in real-time (like uber preview screen)
- Make random, silly, but polished websites such as https://random.country , https://sendnoodz.io/ to train basic webdev skills. Also, Let's Encrypt!
- Twilio SMS / Call / Whatsapp APIs
- Buildroot + Gitlab CI
- Google Repo: Automatic add tagged commit after CI
- Consolidate learnings into a blog / website. Github / gitlab pages would be excellent except for the manual photo management.
- Update top-level README when we create new learnings (CI)
- MQTT+Website: Create a website / backend service that displays some graphs based on data received from MQTT
- Figure out where to host all the web stuff on the cheap
- https://course.fast.ai/
- I'm sure I have other todolists like this from long ago

# Bugs I found and probably should report
- [ ] Git bug where .gitconfig includeif will barf if it comes across some combination of symlink + mountpoint(separate drive) + luks/dm-crypt. Cannot reliably reproduce this other than my specific desktop machine stup yet.
- [ ] Vagrant libvirt plugin does not seem to support emulated TPM 2.0 devices ( checking the xml file templates does not seem to have this option) - probably not much demand for this?
- [ ] Yocto meta-llvm does not seem to handle its sources being archived (makes compile errors)
- [ ] openstlinux setup scropt does not seem to like being started from my zsh shell.
