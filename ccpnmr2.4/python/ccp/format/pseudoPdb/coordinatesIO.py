"""
======================COPYRIGHT/LICENSE START==========================

coordinatesIO.py: I/O for PseudoPDB coordinate files (PDB-like but with no header and undefined atom naming)

Copyright (C) 2006-2008 Wim Vranken (European Bioinformatics Institute)

=======================================================================

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.
 
A copy of this license can be found in ../../../../license/LGPL.license
 
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
Lesser General Public License for more details.
 
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA


======================COPYRIGHT/LICENSE END============================

for further information, please contact :

- CCPN website (http://www.ccpn.ac.uk/)
- PDBe website (http://www.ebi.ac.uk/pdbe/)

- contact Wim Vranken (wim@ebi.ac.uk)
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

import os

# Import general functions
from memops.universal.Util import returnInt, returnFloat

from ccp.format.general.Util import getRegularExpressions
from ccp.format.general.Constants import defaultSeqInsertCode
from ccp.format.general.Constants import defaultAltLoc

from ccp.format.pseudoPdb.generalIO import PseudoPdbGenericFile

#####################
# Class definitions #
#####################

class PseudoPdbCoordinateFile(PseudoPdbGenericFile):

  def initialize(self):
  
    self.modelCoordinates = {}
    
    self.patt.update(getRegularExpressions('pdb'))
    
    self.chains = []

  def read(self,maxNum = 999, ignoreResNames = None, swapFirstNumberAtom = False):

    atomRead = 1
    modelNum = ''
    oldChainId = ''
    
    (baseName,fileName) = os.path.split(self.name)
    compoundName = fileName

    #
    # Read coordinates and other info
    #

    fin = open(self.name, 'rU')
    line = fin.readline()

    while line:
      
      if self.patt['pdbNewModel'].search(line): # Not necessarily there!! Is empty if so
        modelNum = returnInt(self.patt['pdbNewModel'].search(line).group(1))

        if modelNum > maxNum:
          atomRead = 0
          break

        self.modelCoordinates[modelNum] = []

      elif atomRead == 1 and self.patt['pdbAllAtom'].search(line):

        # Case one model only
        if modelNum == '':
          modelNum = 1
          self.modelCoordinates[modelNum] = []

        serial = line[6:11]
        atomName = line[12:16]
        altLoc = line[16:17]
        resName = line[17:20]
        chainId = line[21:22]
        seqCode = line[22:27]
        insertionCode = line[27:28]
        x = line[30:38]
        y = line[38:46]
        z = line[46:54]
        occupancy = line[54:60]
        tempFactor = line[60:66]
        segId = line[72:76]
        
        #
        # Could be PDB-ish file, track heteroatoms
        #
        
        isHeteroAtom = False
        if line.count("HETATM"):
          isHeteroAtom = True
        
        #
        # Merge insertionCode with seqCode if it's a number...
        #
        
        if seqCode[-1] != " " and insertionCode in '0123456789':
          seqCode += insertionCode
          insertionCode = " "
        
        #
        # Ignore residue names (e.g. 'HOH')
        #

        if ignoreResNames and resName.strip() in ignoreResNames:
          line = fin.readline()
          continue

        #
        # Reset atom name if required...
        #
        
        if swapFirstNumberAtom and self.patt['onlydigit'].search(atomName[0]):
          atomName = atomName[1:].strip() + atomName[0]
        
        #
        # Try to figure out what to use as chain code
        #
        
        if segId.strip() and not chainId.strip():
          useChainId = segId.strip()
        elif chainId.strip():
          useChainId = chainId.strip()
        else:
          useChainId = chainId
                
        self.modelCoordinates[modelNum].append(PseudoPdbCoordinate(self,serial,
         atomName,resName,useChainId,chainId,seqCode,x,y,z,segId,
         insertionCode=insertionCode, altLoc=altLoc, tempFactor=tempFactor, occupancy=occupancy, isHeteroAtom=isHeteroAtom))

        if useChainId != oldChainId:
          
          oldChainId = useChainId
          
          foundChain = 0
          
          for chain in self.chains:
            if chain.chainId == useChainId:
              foundChain = 1
              break
              
          if not foundChain:  

            self.chains.append(PseudoPdbChain(useChainId, compoundName = compoundName))

      line = fin.readline()

    fin.close()

  def write(self,verbose = 0):

    if verbose == 1:
      print "Writing %s coordinate file %s" % (self.format,self.name)

    fout = open(self.name,'w')

    #
    # TODO: CURRENTLY NO HEADER!
    #
    
    multipleModels = 0
    
    if len(self.modelCoordinates) > 1:
      multipleModels = 1
      
    modelNums = self.modelCoordinates.keys()
    modelNums.sort()
      
    for modelNum in modelNums:
        
      oldChainId = self.modelCoordinates[modelNum][0].chainId

      if multipleModels:
      
        fout.write("MODEL %7s" % modelNum + self.newline)
        
      for coord in self.modelCoordinates[modelNum]:
      
        if oldChainId != coord.chainId:
          fout.write("TER" + self.newline)
          oldChainId = coord.chainId
      
        atomText = 'ATOM'
        atomFormat = " %-3s"
       
        if self.patt['onlydigit'].search(coord.atomName[0]) or len(coord.atomName) == 4:
          
          atomFormat = "%-4s"
      
        lineFormat = "%-6s%5d " + atomFormat + "%1s%-4s%1s%4d%1s   %8.3f%8.3f%8.3f%6.2f%6.2f      %-4s%2s%2s"

        if coord.origChainId:
          chainId = coord.origChainId
        else:
          chainId = coord.chainId
      
        fout.write(lineFormat %
        
                    (atomText,coord.serial,coord.atomName,'',coord.resName,chainId,
                     coord.seqCode,coord.insertionCode,coord.x,coord.y,coord.z,1.00,0.00,coord.segId,'',''))
                     
        fout.write(self.newline)
            
      fout.write("TER" + self.newline)
      
      if multipleModels:
      
        fout.write("ENDMDL" + self.newline)

    fout.write("END" + self.newline)

    fout.close()

class PseudoPdbChain:

  def __init__(self,chainId, compoundName = None):

    self.chainId = chainId
    
    self.compoundName = None
    if compoundName:
      self.compoundName = compoundName

class PseudoPdbCoordinate:

  def __init__(self,parent,serial,atomName,resName,chainId,origChainId,
               seqCode,x,y,z,segId, insertionCode=defaultSeqInsertCode,
               altLoc=defaultAltLoc,tempFactor=None,occupancy=None,isHeteroAtom=None):
  
    self.parent = parent
    self.serial = returnInt(serial)
    self.atomName = atomName.strip()
    self.resName = resName.strip()
    self.chainId = chainId
    self.origChainId = origChainId
    self.seqCode = returnInt(seqCode)
    self.x = returnFloat(x)
    self.y = returnFloat(y)
    self.z = returnFloat(z)
    self.segId = segId.strip()
    self.insertionCode = insertionCode
    self.altLoc = altLoc
    
    if not self.segId:
      self.segId = self.parent.defaultMolCode
      
    self.bFactor = returnFloat(tempFactor)
    self.occupancy = returnFloat(occupancy,verbose=False)
    
    self.isHeteroAtom = isHeteroAtom

  
