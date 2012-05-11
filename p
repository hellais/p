#!/usr/bin/python
import sys
import os
import sqlite3
import datetime

config_dir = os.path.expanduser('~/.p')
db_file = os.path.join(config_dir, 'p.sqlite')
options = ['rm', 'add']
path_to_script = os.path.join(os.getcwd(), 'p')

def init():
    if not os.path.exists(config_dir):
        os.mkdir(config_dir)

    if not os.path.exists(db_file):
        init_db(db_file)
        init_bash_profile()

def init_bash_profile():
    print "Checking for installed bash profile"
    script = """# p simple shell project manager ~314159265~
function p () {
    echo $@
    %s "$@";
    if [ -f ~/.p/pdir ]; then
        cd `cat ~/.p/pdir`;
        rm -f ~/.p/pdir;
    fi
}
""" % path_to_script
    bash_profile = os.path.expanduser('~/.bash_profile')
    installed = False
    fp = open(bash_profile)
    for x in fp.readlines():
        if 'p simple shell project manager ~314159265~' in x:
            installed = True
            print "[+] Detected previous installation."
    fp.close()
    if not installed:
        print "PSSPM not installed. Installing to bash_profile"
        fp = open(bash_profile, 'a+')
        fp.write('\n')
        fp.write(script)
        fp.write('\n')
        fp.close()
        print "[+] Installation succesful. "
        print "You will need to restart your shell to use"

def init_db(db_file):
    print "No database found. Creating it..."
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    cursor.execute("""create table projects (shortname text, description text, path text,
                      creation_date text, last_accessed text)""")
    conn.commit()
    cursor.close()
    print "[+] Database created."
    print "Adding first project p"
    add_project()

def list_projects():
    print "P, a simple shell project manager"
    print "usage: p (add|rm) <project_name>"
    print ""
    print "Listing active projects"
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    query = """SELECT * FROM projects"""
    for i, row in enumerate(cursor.execute(query)):
        print "---"
        print "name: %s" % row[0]
        print "description: \n %s" % row[1]
        print "path: %s" % row[2]
        print "added: %s" % row[3]
        print "last_accessed: %s" % row[4]
    conn.commit()
    cursor.close()

def project_exists(name):
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()

    query = """SELECT * FROM projects where shortname = ?"""
    cursor.execute(query, (name,))

    if len(cursor.fetchall()) > 0:
        return True
    else:
        return False

    conn.commit()
    cursor.close()

def cd_project(pname):
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()

    if pname and not project_exists(pname):
        print "[!] Project does not exist!"
        pname = None

    while not pname:
        print "Enter project shortname: ",
        r = raw_input()
        if project_exists(r):
            pname = r
        else:
            print "[!] Project does not exist!"

    query = """SELECT * FROM projects where shortname = ?"""
    query_b = """UPDATE projects SET last_accessed = ? where shortname = ?"""

    cursor.execute(query, (pname,))
    row = cursor.fetchone()
    project_dir = row[2]
    print "Changing to %s directory" % project_dir
    fp = open(os.path.join(config_dir, 'pdir'), 'w')
    fp.write(project_dir)
    fp.close()

    cursor.execute(query_b, (datetime.datetime.now(), pname))

    conn.commit()
    cursor.close()

def rm_project(pname):
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    if pname and not project_exists(pname):
        print "[!] Project does not exist!"
        pname = None

    while not pname:
        print "Enter project shortname: ",
        r = raw_input()
        if project_exists(r):
            pname = r
        else:
            print "[!] Project does not exist!"
    print 'I am going to delete "%s" from the project list.' % pname
    print "Do you confirm? (y/n) ",
    r = raw_input()
    if r == 'y':
        query = """DELETE FROM projects where shortname = ?"""
        cursor.execute(query, (pname,))
        print "[+] Deleted %s" % pname
    else:
        print "Aborting..."

    conn.commit()
    cursor.close()

def add_project(shortname=None):
    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    if shortname in options:
        print "[!] Project name must be different from %s" % options
        shortname = None

    if project_exists(shortname):
        print "[!] Project with such name already exists!"
        shortname = None

    while not shortname:
        print "Enter project shortname: ",
        r = raw_input()
        if r in options:
            print "[!] Project name must be different from %s" % options
        else:
            shortname = r

        if project_exists(shortname):
            print "[!] Project with such name already exists!"
            shortname = None

    path = None
    while not path:
        output = "Enter project path (default: %s): " % os.getcwd()
        print output,
        r = raw_input()

        if r == "":
            path = os.getcwd()
        elif os.path.exists(r):
            path = r
        else:
            print "[!] Invalid path!"

    description = None
    while description is None:
        print "Enter project description (optional): "
        r = raw_input()

        if r == "":
            description = ""
        else:
            description = r
    query = "INSERT INTO projects VALUES (?, ?, ?, ?, ?)"
    args = (shortname, description, path,
                      datetime.datetime.now(),
                      datetime.datetime.now())
    cursor.execute(query, args)
    conn.commit()
    cursor.close()

def main():
    init()
    if len(sys.argv) == 1:
        list_projects()
    elif len(sys.argv) > 1:
        pname = None
        if len(sys.argv) > 2:
            pname = sys.argv[2]

        if sys.argv[1] == "add":
            add_project(pname)
        elif sys.argv[1] == "rm":
            rm_project(pname)
        else:
            pname = sys.argv[1]
            cd_project(pname)
    else:
        print "Usage: p (list|add|rm|<project_name>)"

if __name__ == "__main__":
    main()

