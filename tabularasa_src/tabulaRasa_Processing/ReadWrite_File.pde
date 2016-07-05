/*
    ReadWrite_File.pde
    Ver 1.02
    Jan 28 2011
    greg surges
    surgesg@gmail.com
    http://www.gregsurges.com/
     
    This file is part of tabulaRasa.

    tabulaRasa is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    tabulaRasa is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with tabulaRasa.  If not, see <http://www.gnu.org/licenses/>.
*/

void Save() {
  println("Save");  
  for(int i = 0;i < 64;++i) {  //add essential arrays to file
    file[slotInterp_offset +i] = (byte)slotInterp[i];  //add slot_Interp[]
    if(slotStatus[i]) {  //convert boolean to byte
      file[slotStatus_offset + i] = 1;  //add slotStatus[]
    }
    else {
      file[slotStatus_offset + i] = 0;
    }
  }
  for(int i = 0;i < 16 *32  * 2; ++i) {
    file[sliderData_offset + i] = (byte)sliderData[i];  //add sliderData[]
  }
  String fileName;  //composite file (all arrays)
  fileName = "data.dat";  //always save to this file
  fileDelete(fileName);
  saveBytes(fileName, file);  //write all data to file now
}
void fileDelete(String DEST_FILE) {  //Windows 7 will not rename tmp files
  File dataFile = sketchFile(DEST_FILE);
  if (dataFile.exists()) {
    dataFile.delete(); // Returns false if it cannot do it
  }
}
void Load() {
  // open a file and read its binary data 
  println("Load");  
  String path = selectInput();  //choose the input file
  file = loadBytes(path); 
  for (int i = 0; i < 64; i++) { 
    slotInterp[i] = file[slotInterp_offset + i] & 0xff;  //populate slotInterp[]
    slotStatus[i] = boolean(file[slotStatus_offset + i]);  //populate slotStatus[]
  } 
  for (int i = 0; i < 16 * 32 * 2; i++) { 
    sliderData[i] = file[sliderData_offset + i] & 0xff;  //convert to integer and load sliderData[]
  } 
  interpType = slotInterp[currentSlot];  //get current interpType
  loadSliders();
  highlightMem();
  highlightInterp();
}

void copyWave() {
  println("Copy");  
  for(int i = 0; i < 16; ++i) {
    copyBuffer[i] = sliderData[i + (16 * (currentSlot))];
  }
  interpBuffer = interpType;
  if(interpType == 6) {
     for(int i = 0; i < 256; ++i) {  //update the data array
          dataBuffer[i] = file[i + (256 * (currentSlot))];
      }
  }
}

void pasteWave() {
  println("Paste");  
  for(int i = 0; i < 16; ++i) {
    sliderData[i + (16 * (currentSlot))] = copyBuffer[i];
  }
  interpType = interpBuffer;
  if(interpType == 6) {
     for(int i = 0; i < 256; ++i) {  //update the data array
          file[i + (256 * (currentSlot))] = dataBuffer[i];
      }
  }
  loadSliders();
  slotStatus[currentSlot] = true;
}
