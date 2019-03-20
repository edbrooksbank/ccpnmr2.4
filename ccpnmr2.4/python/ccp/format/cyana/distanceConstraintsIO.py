
"""
======================COPYRIGHT/LICENSE START==========================

distanceConstraintsIO.py: I/O for Cyana distance constraint files

Copyright (C) 2005 Wim Vranken (European Bioinformatics Institute)

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
from memops.universal.Io import getTopDirectory

from ccp.format.dyana.distanceConstraintsIO import DyanaDistanceConstraintFile
from ccp.format.dyana.distanceConstraintsIO import DyanaDistanceConstraint
from ccp.format.cyana.generalIO import getFormat

class CyanaDistanceConstraintFile(DyanaDistanceConstraintFile):

  def setFormat(self):

    self.format = getFormat()

  def write(self,verbose = 0, noAmbiguous = 0):

    if verbose == 1:
    
      fileText = self.name
      
      if self.lowerDistanceFile:
        fileText += ' and %s.' % self.lowerDistanceFile

      print "Writing %s distance constraint list %s" % (self.format,fileText)
    
    #
    # CYANA can handle ambiguous...
    #
    
    self.writeGeneric(noAmbiguous = noAmbiguous)

class CyanaDistanceConstraint(DyanaDistanceConstraint):

  pass

if __name__ == "__main__":

  files = ['../../reference/diana/1bc6.restr',
           '../../reference/diana/u1c.upl',
           '../../reference/cyana2.1/cycle3.upl']
  
  for file in files[-1:]:
    
    file = os.path.join(getTopDirectory(), file)
    
    constraintFile = CyanaDistanceConstraintFile(file)

    constraintFile.read(verbose = 1)
  
    for constraint in constraintFile.constraints:
      print constraint.Id,
      
      print constraint.upperDist,
      print constraint.peakNum, constraint.qualityFactor
      for item in constraint.items:
        print item.support,
        for member in item.members:
          print member.seqCode, member.atomName,
        print "|",
      
      print

    #constraintFile.name = 'local/dist.testout.upl'
    #constraintFile.lowerDistanceFile = 'local/dist.testout.lol'

    #constraintFile.write(verbose = 1)
