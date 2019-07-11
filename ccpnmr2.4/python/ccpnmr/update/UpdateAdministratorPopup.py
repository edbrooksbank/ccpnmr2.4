"""
======================COPYRIGHT/LICENSE START==========================

UpdateAdministratorPopup.py: Part of the CcpNmr Update program

Copyright (C) 2003-2010 Wayne Boucher and Tim Stevens (University of Cambridge)

=======================================================================

The CCPN license can be found in ../../../license/CCPN.license.

======================COPYRIGHT/LICENSE END============================

for further information, please contact :

- CCPN website (http://www.ccpn.ac.uk/)

- email: ccpn@bioc.cam.ac.uk

- contact the authors: wb104@bioc.cam.ac.uk, tjs23@cam.ac.uk
=======================================================================

If you are using this software for academic purposes, we suggest
quoting the following references:

===========================REFERENCE START=============================
R. Fogh, J. Ionides, E. Ulrich, W. Boucher, W. Vranken, J.P. Linge, M.
Habeck, W. Rieping, T.N. Bhat, J. Westbrook, K. Henrick, G. Gilliland,
H. Berman, J. Thornton, M. Nilges, J. Markley and E. Laue (2002). The
CCPN project: An interim report on a data model for the NMR community
(Progress report). Nature Struct. Biol. 9, 416-418.

Wim F. Vranken, Wayne Boucher, Tim J. Stevens, Rasmus
H. Fogh, Anne Pajon, Miguel Llinas, Eldon L. Ulrich, John L. Markley, John
Ionides and Ernest D. Laue (2005). The CCPN Data Model for NMR Spectroscopy:
Development of a Software Pipeline. Proteins 59, 687 - 696.

===========================REFERENCE END===============================

"""
import os, sys
import Tkinter
import re
from subprocess import Popen, PIPE

from memops.gui.BasePopup       import BasePopup
from memops.gui.Entry           import Entry
from memops.gui.FileSelect      import FileType
from memops.gui.FileSelectPopup import FileSelectPopup
from memops.gui.IntEntry        import IntEntry
from memops.gui.Label           import Label
from memops.gui.MessageReporter import showWarning
from memops.gui.ScrolledMatrix  import ScrolledMatrix

from memops.gui.ButtonList      import ButtonList
from memops.gui.Frame           import Frame
from memops.gui.ScrolledListbox import ScrolledListbox

from memops.universal.Io import splitPath

from ccpnmr.update.UpdateAgent import UpdateAgent, FileUpdate, UPDATE_SERVER_LOCATION, UPDATE_DIRECTORY, UPDATE_DATABASE_FILE, UPDATE_BASE_DIRECTORY
from ccpnmr.analysis.Version import version


SERVERUSER = 'ccpn'
BASEBRANCH = 'master'
UPDATEBRANCH = 'ccpnmr2.4.3.b1'
DEFAULTFILTER = ''


def runGitCommand(command):
  gitCommand = ['git', ] + command.split()
  gitQuery = Popen(gitCommand, stdout=PIPE, stderr=PIPE)
  gitStatus, error = gitQuery.communicate()
  if gitQuery.poll() == 0:
    return gitStatus.decode("utf-8").strip()


def osCommand(command):
  osCommand = command.split()
  osQuery = Popen(osCommand, stdout=PIPE, stderr=PIPE)
  osStatus, osError = osQuery.communicate()
  if osQuery.poll() == 0:
    return osStatus.decode("utf-8").strip()


class UpdateAdministratorPopup(BasePopup, UpdateAgent):

  def __init__(self, parent, 
               serverLocation=UPDATE_SERVER_LOCATION,
               serverDirectory=UPDATE_BASE_DIRECTORY+version,
               dataFile=UPDATE_DATABASE_FILE):
    
    UpdateAgent.__init__(self, serverLocation, serverDirectory, dataFile, admin=1)

    self.fileTypes = [  FileType('Python', ['*.py']), FileType('C', ['*.c']), FileType('All', ['*'])]
    self.fileUpdate = None
    self._serverVersion = None

    BasePopup.__init__(self, parent=parent, title='CcpNmr Update Administrator', quitFunc=self.quit)

  def body(self, guiParent):
  
    guiParent.grid_columnconfigure(3, weight=1)
    
    self.commentsEntry = Entry(self)
    self.priorityEntry = IntEntry(self)
    
    
    row = 0
    label = Label(guiParent, text='Server location:')
    label.grid(row=row, column=0, sticky='w')

    location = ''
    uid      = ''
    httpDir   = ''
    subDir   = ''
    version  = 'None'
    
    if self.server:
      location, uid, httpDir, subDir = self.server.identity
      version = self.server.version or 'None'
    
    self.serverEntry = Entry(guiParent, text=location)
    self.serverEntry.grid(row=row, column=1, stick='w')

    label = Label(guiParent, text='User ID:')
    label.grid(row=row, column=2, sticky='w')
    self.uidEntry = Entry(guiParent, text=uid)
    self.uidEntry.grid(row=row, column=3, stick='w')

    row += 1
    label = Label(guiParent, text='HTTP directory:')
    label.grid(row=row, column=0, sticky='w')
    self.httpDirEntry = Entry(guiParent, text=httpDir)
    self.httpDirEntry.grid(row=row, column=1, stick='w')

    label = Label(guiParent, text='Sub-directory:')
    label.grid(row=row, column=2, sticky='w')
    self.subDirEntry = Label(guiParent, text=subDir)
    self.subDirEntry.grid(row=row, column=3, stick='w')
    # self.subDirEntry.bind('<Return>', self.editSubDirectory)

    row += 1
    self.localVerLabel = Label(guiParent, text='Local version: %s' % self.version)
    self.localVerLabel.grid(row=row, column=0, sticky='w')

    label = Label(guiParent, text='Server version:')
    label.grid(row=row, column=2, sticky='w')
    self.serverVersionEntry = Entry(guiParent, text=version)
    self.serverVersionEntry.grid(row=row, column=3, stick='w')
    self.serverVersionEntry.bind('<Return>', self.editServerVersion)

    row += 1
    guiParent.grid_rowconfigure(row, weight=1)
    headingList = ['File','Location','Date','Priority','Comments','StoredAs',]

    editWidgets      = [ None, None, None, self.priorityEntry, self.commentsEntry ]
    editGetCallbacks = [ None, None, None, self.getPriority,   self.getComments   ]
    editSetCallbacks = [ None, None, None, self.setPriority,   self.setComments   ]
    self.scrolledMatrix = ScrolledMatrix(guiParent, headingList=headingList,
                                         multiSelect=True,
                                         editWidgets=editWidgets, callback=self.selectCell,
                                         editGetCallbacks=editGetCallbacks,
                                         editSetCallbacks=editSetCallbacks)
    self.scrolledMatrix.grid(row=row, column=0, columnspan=4, sticky='nsew')

    row += 1
    texts = ['Add\nFiles','Remove\nFiles','Remove\nAll','Query\nServer','Commit\nSelected','Synchronise\nAll','Commit\nNew', 'Quit']
    commands = [self.addFile, self.removeFile, self.removeAll, self.queryFiles, self.synchroniseSelected, self.synchroniseServer, self.updateServer, self.quit]
    self.buttonList = ButtonList(guiParent, texts=texts, commands=commands, expands=1)
    self.buttonList.grid(row=row, column=0, columnspan=4, sticky='ew')

    row += 1
    self.commitFrame = Frame(guiParent)
    self.commitFrame.grid(row=0, column=4, rowspan=row, columnspan=1, sticky='ns')
    self.setupCompareFrame(self.commitFrame)

    self.update()

  def getPriority(self, fileUpdate):
  
    if fileUpdate:
      self.priorityEntry.set(fileUpdate.priority)
  
  def setPriority(self, event):

    i = self.priorityEntry.get()
    if self.fileUpdate:
      self.fileUpdate.priority = i
    
    self.update()

  def getComments(self, fileUpdate):

    if fileUpdate:
      self.commentsEntry.set(fileUpdate.details)
  
  def setComments(self, event):

    text = self.commentsEntry.get()
    if self.fileUpdate:
      self.fileUpdate.details = text
    
    self.update()

  def quit(self):
  
    self.close()
    self.destroy()
    sys.exit()


  def updateServer(self):
  
    if self.server:
      # Unly upload new updates
      success = self.server.setFileUpdates()
      # self.serverLabel.set('Server version: %s' % self.server.version)
      self.serverVersionEntry.set(self.server.version)
      if success:
        self.queryFiles()

  def synchroniseSelected(self):
  
    if self.server:
      selectedUpdates = self.scrolledMatrix.currentObjects
      if selectedUpdates:
        # Refresh all selected updates
        success = self.server.setFileUpdates(fileUpdates=selectedUpdates, refresh=True)
        # self.serverLabel.set('Server version: %s' % self.server.version)
        self.serverVersionEntry.set(self.server.version)
        if success:
          self.queryFiles()

  def synchroniseServer(self):
  
    if self.server:
      # Refresh all available updates
      success = self.server.setFileUpdates(refresh=True)
      # self.serverLabel.set('Server version: %s' % self.server.version)
      self.serverVersionEntry.set(self.server.version)
      if success:
        self.queryFiles()

  def queryFiles(self):
  
    if self.server:
      self.server.getFileUpdates()
        
    self.update()

  def addFile(self):
  
    if self.server:
      fileSelectPopup = FileSelectPopup(self, title='Select Source File', dismiss_text='Cancel', 
                                        file_types=self.fileTypes, multiSelect=True, 
                                        selected_file_must_exist=True)
      
      filePaths = fileSelectPopup.file_select.getFiles()
      n = len(self.installRoot)

      for filePath in filePaths:
        if self.installRoot != filePath[:n]:
          showWarning('Warning','Install root %s not found in file path %s' % (self.installRoot, filePath))
          continue
 
        filePath = filePath[n+1:]
 
        if filePath:
          dirName, fileName = splitPath(filePath)
 
          if fileName[-3:] == '.py':
            language = 'python'
          else:
            language = 'None'
 
          fileUpdate = FileUpdate(self.server, fileName, dirName, language, isNew=True)
 
      self.update()
     

  def removeFile(self):
  
    if self.fileUpdate:
      self.fileUpdate.delete()
     
      self.update() 

  def removeAll(self):
  
    if self.server:
      for fileUpdate in list(self.server.fileUpdates):
        fileUpdate.delete()

      self.update() 
 
  def selectAll(self):
  
    if self.server:
      for fileUpdate in self.server.fileUpdates:
        fileUpdate.isSelected = 1
        
    self.update()

  def selectCell(self, object, row, col):
  
    self.fileUpdate = object
    self.updateButtons()

  def updateButtons(self):
  
    buttons = self.buttonList.buttons
    
    if self.server:
      buttons[0].enable()
      buttons[3].enable()
      buttons[4].enable()
    else:
      buttons[0].disable()  
      buttons[3].disable()  
      buttons[4].disable()  
    
    if self.server and self.server.fileUpdates:
      buttons[2].enable()
    else:
      buttons[2].disable()  

    if self.fileUpdate:
      buttons[1].enable()
    else:
      buttons[1].disable()  
      
  def update(self):
    
    location = self.serverEntry.get()
    uid      = self.uidEntry.get()
    httpDir   = self.httpDirEntry.get()
    subDir   = self.subDirEntry.get()
    if self.server:
      if (location,uid,httpDir,subDir) != self.server.identity:
        # self.setServer(location)
        self.setServer(location, self.serverDirectory, self.dataFile, httpDir, admin=False)

    self.updateButtons()
    
    self.fileUpdate = None
    textMatrix  = []
    objectList  = []
    colorMatrix = []
    
    if self.server:
      
      for fileUpdate in self.server.fileUpdates:
                
        datum = []
        datum.append(fileUpdate.fileName)
        datum.append(fileUpdate.filePath)
        datum.append(fileUpdate.date)
        datum.append(fileUpdate.priority)
        datum.append(fileUpdate.details)
        datum.append(fileUpdate.storedAs)
        
        textMatrix.append(datum)
        objectList.append(fileUpdate)
        if fileUpdate.isNew:
          colorMatrix.append(5 * ['#B0FFB0'])
        
        elif not fileUpdate.getIsUpToDate():
          colorMatrix.append(5 * ['#FFB0B0'])
        
        else:
          colorMatrix.append(5 * [None])

    self.scrolledMatrix.update(textMatrix=textMatrix, objectList=objectList, colorMatrix=colorMatrix)
    

  def setupCompareFrame(self, frame):
    """Set up the widgets in the compare branches frame
    """
    row = 0
    label = Label(frame, text='Compare Git Branches:')
    label.grid(row=row, column=0, rowspan=1, columnspan=2)

    row += 1
    label = Label(frame, text='Base Branch:')
    label.grid(row=row, column=0, stick='w')
    self._lineEditBase = Entry(frame, text=BASEBRANCH)
    self._lineEditBase.grid(row=row, column=1, stick='w')
    # self._lineEditBase.returnPressed.connect(self.editCompareBranches)

    row += 1
    label = Label(frame, text='Updates Branch:')
    label.grid(row=row, column=0, stick='w')
    self._lineEditUpdate = Entry(frame, text=UPDATEBRANCH)
    self._lineEditUpdate.grid(row=row, column=1, stick='w')
    # self._lineEditUpdate.returnPressed.connect(self.editCompareBranches)

    row += 1
    label = Label(frame, text='Filter by ExtensionType:')
    label.grid(row=row, column=0, stick='w')
    self._filterEntry = Entry(frame, text=DEFAULTFILTER)
    self._filterEntry.grid(row=row, column=1, stick='w')
    self._filterEntry.bind('<Return>', self.editFilter)

    row += 1
    self._branchList = ScrolledListbox(frame, xscroll=False, selectmode=Tkinter.EXTENDED)
    self._branchList.grid(row=row, column=0, rowspan=1, columnspan=2, sticky='nsew')
    # make the list expand to fill the space
    frame.grid_rowconfigure(row, weight=1)

    row += 1
    texts = ['Check Server', 'Add Selected Files']
    commands = [self._checkBranchServer, self._addSelectedToCommits]
    buttonList = ButtonList(frame, texts=texts, commands=commands)    #, expands=1)
    buttonList.grid(row=row, column=0, rowspan=1, columnspan=2)   #, sticky='ew')
    self._fillCompareList()

  def _fillCompareList(self, currentPath = os.getcwd()):

    # need to make sure that the working directory is set to the base directory of the project

    # clear the lists
    self._branchList.clear()
    self._allFiles = set()

    # get the current repositories attached to this path
    gitRepositories = osCommand('find . -name .git')
    if gitRepositories:

        # go through the list
        for gitRep in gitRepositories.split():

            dir = os.path.dirname(os.path.join(currentPath, gitRep))
            localDir = os.path.dirname(gitRep)[2:]
            os.chdir(dir)

            # get the different files between the branches for this repository
            gitCmd = 'diff --name-only %s %s' % (self._lineEditBase.get(), self._lineEditUpdate.get())
            _files = runGitCommand(gitCmd)
            if _files:

                # check errors first, and add to the list
                # [self._allFiles.add(os.path.join(localDir, path)) for path in _files.split()]
                [self._allFiles.add(os.path.join(os.getcwd(), path)) for path in _files.split()]

                filter = self._filterEntry.get()
                if filter:
                  # simple filter by file extension
                  self._allFiles = [filePath for filePath in self._allFiles if os.path.splitext(filePath)[-1].lower() == filter]

    # # populate the list with the files
    n = len(self.installRoot)
    self._allFiles = [filePath[n+1:] for filePath in self._allFiles]
    self._branchList.setItems(self._allFiles)

    # restore the current working directory
    os.chdir(currentPath)
    self._checkBranchServer()

  def _addSelectedToCommits(self):
    """Add the selected files to the server list
    """
    branchFiles = self._branchList.getSelectedItems()
    selectedFilePaths = [os.path.join(self.installRoot, item) for item in branchFiles]

    filePaths = [fileUpdate.installedFile for fileUpdate in self.server.fileUpdates]

    n = len(self.installRoot)
    for ii, filePath in enumerate(selectedFilePaths):
        # colour depending on whether on the server
      if self.installRoot != filePath[:n]:
        showWarning('Warning', 'Install root %s not found in file path %s' % (self.installRoot, filePath))
        continue

      filePath = filePath[n + 1:]

      if filePath:
        dirName, fileName = splitPath(filePath)

        if fileName[-3:] == '.py':
          language = 'python'
        else:
          language = 'None'

        fileUpdate = FileUpdate(self.server, fileName, dirName, language, isNew=True)

    self.update()

    # return
    #
    # branchFiles = self._branchList.getSelectedTexts()
    # selectedFilePaths = [os.path.join(os.getcwd(), item) for item in branchFiles]
    #
    # self.addFiles(selectedFilePaths)
    # self.updateTable.setObjects(self.updateFiles)
    #
    #
    # for filePath in filePaths:
    #   if self.installRoot != filePath[:n]:
    #     showWarning('Warning', 'Install root %s not found in file path %s' % (self.installRoot, filePath))
    #     continue
    #
    #   filePath = filePath[n + 1:]
    #
    #   if filePath:
    #     dirName, fileName = splitPath(filePath)
    #
    #     if fileName[-3:] == '.py':
    #       language = 'python'
    #     else:
    #       language = 'None'
    #
    #     fileUpdate = FileUpdate(self.server, fileName, dirName, language, isNew=True)
    #
    # self.update()

  def _checkBranchServer(self):
    """colour the files depending on whether they are already on the server
    """
    branchFiles = self._branchList.getItems()
    filePaths = [os.path.join(fileUpdate.filePath, fileUpdate.fileName) for fileUpdate in self.server.fileUpdates]

    if self._filterEntry.get():
      filter = self._filterEntry.get()
      filePaths = [filePath for filePath in filePaths if filePath.endswith(filter)]

    for ii, item in enumerate(branchFiles):
        # colour depending on whether on the server

        # # remove the leading fileroot
        # n = len(self.installRoot)
        # for ii, filePath in enumerate(selectedFilePaths):
        #
        #   if self.installRoot != filePath[:n]:
        #     showWarning('Warning', 'Install root %s not found in file path %s' % (self.installRoot, filePath))
        #     continue
        #
        #   filePath = filePath[n + 1:]

        if item in filePaths:
          self._branchList.itemconfig(ii, {'fg': 'black'})
        else:
          self._branchList.itemconfig(ii, {'fg': 'red'})

  def editFilter(self, *args):
    """return pressed in the filter box - update the filter list
    """
    self._fillCompareList()

  def editSubDirectory(self, *args):
    """Edit the path on the server
    """
    self._updateServerSettings()

  def editServerVersion(self, *args):
    """Change the serverVersion to update different branch
    """
    self._updateServerSettings()

  def _updateServerSettings(self):
    """Update the settings so that admin points to different server location
    """
    from ccpnmr.analysis import Version

    if self.server:
      newVersion = self.serverVersionEntry.get()
      self.server.parent.version = newVersion
      self.server.version = newVersion
      Version.version = newVersion

      UpdateAgent.__init__(self, serverLocation=UPDATE_SERVER_LOCATION,
                            serverDirectory=UPDATE_BASE_DIRECTORY+newVersion,
                            dataFile=UPDATE_DATABASE_FILE, admin=1)

      # update text boxes
      if self.server:
        location, uid, httpDir, subDir = self.server.identity
        version = self.server.version or 'None'

        self.serverEntry.set(location)
        self.uidEntry.set(uid)
        self.httpDirEntry.set(httpDir)
        self.subDirEntry.set(subDir)
        self.localVerLabel.set('Local version: %s' % self.version)
        self.serverVersionEntry.set(version)

      # update the display
      self.queryFiles()
      self._fillCompareList()


if __name__ == '__main__':

  root = Tkinter.Tk()
  root.withdraw()
  # server location, temp dir, dataFile
  top = UpdateAdministratorPopup(root)
  root.mainloop()
