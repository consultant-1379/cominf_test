#!/bin/bash
# Usage: build.sh <rstate>

G_SCRIPTDIR=$(cd $(/usr/bin/dirname $0); pwd)
G_SPECFILE=$G_SCRIPTDIR/SPECS/specFile
/bin/rm -rf $G_SCRIPTDIR/RPMS || {
	echo "Failed to remove existing RPMS directory"
	exit 1
}

mkdir -p $G_SCRIPTDIR/SRPMS &&
mkdir -p $G_SCRIPTDIR/BUILD &&
mkdir -p $G_SCRIPTDIR/BUILDROOT &&
mkdir -p $G_SCRIPTDIR/RPMS || {
	echo "Failed to create required directories"
	exit 1
}

cd $G_SCRIPTDIR

if [ ! -f $G_SPECFILE ]; then
	echo "Error: unable to find $G_SPECFILE"
	exit 1
fi
NEW_RSTATE=$1

GIT_BRANCH=$2
if [ -z "$GIT_BRANCH" ]; then
	echo "Assuming master branch is to be built"
	GIT_BRANCH=master
fi

git checkout $GIT_BRANCH
echo "Performing a 'git pull'"
git pull > /dev/null 2>&1 || {
	echo "Error - git pull failed"
	exit 1
}

rpm_name=$( grep "^Name:" $G_SPECFILE | awk -F: '{ print $2 }' )
exist_rstate=$( grep "^Version:" $G_SPECFILE | awk -F: '{ print $2 }' )

if [ -z "$NEW_RSTATE" ]; then
	echo "new rstate not specified - will auto-increment existing rstate \"$exist_rstate\""
	perl -pi -e 'if(/^(Version:.*)(\d{2})$/){$a=$2;$_=sprintf("${1}%02d\n",++$a);}' $G_SPECFILE || {
		echo "Error - failed to auto-increment existing rstate"
		exit 1
	}
else
	sed "s/^Version:.*/Version: $NEW_RSTATE/" $G_SPECFILE > $G_SPECFILE.tmp &&
	mv -f $G_SPECFILE.tmp $G_SPECFILE || {
		echo "Error - failed to auto-increment existing rstate"
		exit 1
	}
fi


echo "Building rpm for $rpm_name"
/usr/bin/rpmbuild --quiet -ba $G_SCRIPTDIR/SPECS/specFile || {
	echo "Error - failed to build rpm"
	exit 1
}

# check if specFile has been updated and push updated specfile
git status | grep $( basename $G_SPECFILE ) > /dev/null && {
	echo "Committing updated spec file $G_SPECFILE"
	git add $G_SPECFILE > /dev/null 2>&1 &&
	git commit -m "new state for $rpm_name" > /dev/null 2>&1 &&
	git push > /dev/null 2>&1 || {
		echo "Error - failed to push updated specFile"
		exit 1
	}
}

exit 0




