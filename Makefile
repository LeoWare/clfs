
all: update-scripts build

update-scripts:
	cp -aurv /home/samuel/src/clfs/config.inc /mnt/clfs/usr/src/clfs/
	cp -aurv /home/samuel/src/clfs/function.inc /mnt/clfs/usr/src/clfs/
	cp -aurv /home/samuel/src/clfs/scripts/* /mnt/clfs/usr/src/clfs/scripts/
	cp -aurv /home/samuel/src/clfs/build-clfs /mnt/clfs/usr/src/clfs/
	cp -aurv /home/samuel/src/clfs/build-shell.sh /mnt/clfs/usr/src/clfs/
	cp -aurv /home/samuel/src/clfs/bootfiles.sh /mnt/clfs/usr/src/clfs/
	cp -aurv /home/samuel/src/clfs/toolchain.sh /mnt/clfs/usr/src/clfs/
	cp -aurv /home/samuel/src/clfs/Makefile /mnt/clfs/usr/src/clfs/

build: logs/build.completed
	./build-clfs

build-shell:
	sh build-shell.sh

clean:
	rm -rf /cross-tools/*
	rm -rf /tools/*
	rm -rf /mnt/clfs/{bin,boot,dev,etc,home,lib,lib64,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,var}
	rm -rf /mnt/clfs/usr/{bin,include,lib,lib64,local,sbin,share}
	chown -R clfs:clfs /mnt/clfs
	cp clfs-bashrc /home/clfs/.bashrc
	chown clfs:clfs /home/clfs/.bashrc
	rm -f logs/*
	rm -rf build/*

logs/build.completed: ;
