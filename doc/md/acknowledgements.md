Acknowledgements
=======================================

The contents of the file ACKNOWLEDGEMENTS.txt is listed below.


```text

Acknowledgements

This project incorporates code from a number of external sources, and we are
grateful to the authors for making the code available. To the best of our
knowledge this information is complete and correct; however, we apologise
for any unintentional errors and/or omissions, and will endeavour to correct
these if made aware of them.

% --------------------------------------------------------------------------- %

The CHIPS class CalcFindROIsFLIKA (and other associated classes) are based on
the algorithm described in the following paper:

- Ellefsen KL, Settle B, Parker I, Smith IF. An algorithm for automated
  detection, localization and measurement of local calcium signals from
  camera-based imaging. Cell Calcium. 2014 56(3):147-56.

This algorithm is also available as a standalone python package at
http://flika-org.github.io/.  The original MATLAB code, which we have
modified in our implementation, was kindly provided to us by Kyle Ellefsen and
Ian Smith under the MIT License.

FLIKA - Copyright (c) 2015-2017 Kyle Ellefsen

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

% --------------------------------------------------------------------------- %

The CHIPS class CalcFindROIsCellSort (and other associated classes) are based
on the algorithm described in the following paper:

- Mukamel EA, Nimmerjahn A, Schnitzer MJ. Automated Analysis of Cellular
  Signals from Large-Scale Calcium Imaging Data. Neuron. 2009 63(6):747-60.

The original MATLAB code implementing this algorithm, which we have
modified in our implementation, is available on github at
https://github.com/mukamel-lab/CellSort, and was kindly released to us by
Eran Mukamel under the GNU General Public License v3.

CellSort - Copyright (c) 2009  Eran Mukamel

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

% --------------------------------------------------------------------------- %

The CHIPS function utils.motion_correction, when using the 'hmm' method (Hidden
Markov Model), uses the algorithm and a number of functions described in the
following paper:

- Dombeck DA, Khabbaz AN, Collman F, Adelman TL, Tank DW. Imaging Large-Scale
  Neural Activity with Cellular Resolution in Awake, Mobile Mice. Neuron.
  2007 56(1):43â€“57.

The original MATLAB code, which we have modified in our implementation, was
kindly released to us by David Tank, Daniel Dombeck, and Forrest Collman, under
the GNU General Public License v3.

CellSort - Copyright (c) 2009  Forrest Collman et al.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

% --------------------------------------------------------------------------- %

Although the code itself was not used directly, we are also greatful to the
authors of the following papers for releasing or otherwise making versions of
their algorithms and/or code available.

The CHIPS class CalcVelocityRadon (and other associated classes) are based
on the algorithm described in the following paper:

- Drew PJ, Blinder P, Cauwenberghs G, Shih AY, Kleinfeld D. Rapid determination
  of particle velocity from space-time images using the Radon transform.
  Journal of Computational Neuroscience. 2010;29(1-2):5-11

The CHIPS class CalcVelocityLSPIV (and other associated classes) are based
on the algorithm described in the following paper:

- Kim TN, Goodwill PW, Chen Y, Conolly SM, Schaffer CB, Liepmann D, et al.
  Line-scanning particle image velocimetry: an optical approach for quantifying
  a wide range of blood flow speeds in live animals. PLoS One. 2012;7(6):e38590

The CHIPS class CalcDiameterTiRS (and other associated classes) are based
on the algorithm described in the following paper:

- Gao Y-R, Drew PJ. Determination of vessel cross-sectional area by
  thresholding in Radon space. J Cereb Blood Flow Metab. 2014;34(7):1180-7

% --------------------------------------------------------------------------- %

The following files/functions are copyright the authors (as listed) according
to the terms of the Revised BSD licence as listed at the bottom of this section

- "patchline", (c) 2014, The MathWorks, Inc., retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/36953

- "makeColorMap", (c) 2016, The MathWorks, Inc., retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/17552

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution
    * Neither the name of the The MathWorks, Inc. nor the names
      of its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

% --------------------------------------------------------------------------- %

The following files/functions are copyright the authors (as listed) according
to the terms of the Revised BSD licence as listed at the bottom of this section

- "sc" and its associated files, (c) 2014, Oliver J. Woodford, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/16233. We have modified
  the original code in our implementation.


All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the {organization} nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

% --------------------------------------------------------------------------- %

The following files/functions are copyright the authors (as listed) according
to the terms of the Revised BSD licence as listed at the bottom of this section

- "inpaintn", (c) 2013, Damien Garcia, retrieved from
	http://www.mathworks.com/matlabcentral/fileexchange/27994

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution
    * Neither the name of the RUBIC - Research Unit of Biomechanics & Imaging in Cardiology nor the names
      of its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

% --------------------------------------------------------------------------- %

The following files/functions are copyright the authors (as listed) according
to the terms of the FreeBSD licence as listed at the bottom of this section

- "bresenham", Copyright (c) 2010, Aaron Wetzler, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/28190.

- "convnfft" and related functions, Copyright (c) 2009, Bruno Luong, retrieved
  from http://www.mathworks.com/matlabcentral/fileexchange/24504. We have
  modified the original code in our implementation.

- "cell2csv", Copyright (c) 2004-2010, Sylvain Fiedler, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/4400.

- "GetFullPath", Copyright (c) 2010, Jan Simon, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/28249.

- "lsqnonnegvect", Copyright (c) 2016, David Provencher, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/47476.

- "mtit", Copyright (c) 2009, urs (us) schwarz, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/3218.

- "mygaussfit", Copyright (c) 2007, Yohanan Sivan, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/11733. We have modified
  the original code in our implementation.

- "parsepropval", Copyright (c) 2009, Douglas M. Schwarz, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/22671. We have modified
  the original code in our implementation.

- "saveastiff", Copyright (c) 2016, YoonOh Tak, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/35684. We have modified
  the original code in our implementation.

- "slidefun", Copyright (c) 2015, Jos van der Geest, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/12550.

- "txtmenu", Copyright (c) 2013, Sky Sartorius, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/28285.

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in
  the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

% --------------------------------------------------------------------------- %

The following files/functions are copyright the authors (as listed) according
to the terms of the MIT licence as listed at the bottom of this section

- "boundedline", Copyright (c) 2015 Kelly Kearney, retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/27485. We have modified
  the original code in our implementation.

- "publishreadme-pkg", Copyright (c) 2016 Kelly Kearney, retrieved from
  https://github.com/kakearney/publishreadme-pkg. We have modified the
  original code in our implementation.

- "mxdom2md.xsl", Copyright (c) 2015 Aslak Grinsted, retrieved from
  https://github.com/grinsted/gwmcmc/blob/master/private/mxdom2md.xsl. We
  have modified the original code in our implementation.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% --------------------------------------------------------------------------- %

The following files/functions are copyright the authors (as listed) according
to the terms of the Apache licence v2.0 as listed at the bottom of this section

- "cubehelix", Copyright (c) 2015 Stephen Cobeldick, retrieved from
  https://www.mathworks.com/matlabcentral/fileexchange/43700.

Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

   TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION

   1. Definitions.

      "License" shall mean the terms and conditions for use, reproduction,
      and distribution as defined by Sections 1 through 9 of this document.

      "Licensor" shall mean the copyright owner or entity authorized by
      the copyright owner that is granting the License.

      "Legal Entity" shall mean the union of the acting entity and all
      other entities that control, are controlled by, or are under common
      control with that entity. For the purposes of this definition,
      "control" means (i) the power, direct or indirect, to cause the
      direction or management of such entity, whether by contract or
      otherwise, or (ii) ownership of fifty percent (50%) or more of the
      outstanding shares, or (iii) beneficial ownership of such entity.

      "You" (or "Your") shall mean an individual or Legal Entity
      exercising permissions granted by this License.

      "Source" form shall mean the preferred form for making modifications,
      including but not limited to software source code, documentation
      source, and configuration files.

      "Object" form shall mean any form resulting from mechanical
      transformation or translation of a Source form, including but
      not limited to compiled object code, generated documentation,
      and conversions to other media types.

      "Work" shall mean the work of authorship, whether in Source or
      Object form, made available under the License, as indicated by a
      copyright notice that is included in or attached to the work
      (an example is provided in the Appendix below).

      "Derivative Works" shall mean any work, whether in Source or Object
      form, that is based on (or derived from) the Work and for which the
      editorial revisions, annotations, elaborations, or other modifications
      represent, as a whole, an original work of authorship. For the purposes
      of this License, Derivative Works shall not include works that remain
      separable from, or merely link (or bind by name) to the interfaces of,
      the Work and Derivative Works thereof.

      "Contribution" shall mean any work of authorship, including
      the original version of the Work and any modifications or additions
      to that Work or Derivative Works thereof, that is intentionally
      submitted to Licensor for inclusion in the Work by the copyright owner
      or by an individual or Legal Entity authorized to submit on behalf of
      the copyright owner. For the purposes of this definition, "submitted"
      means any form of electronic, verbal, or written communication sent
      to the Licensor or its representatives, including but not limited to
      communication on electronic mailing lists, source code control systems,
      and issue tracking systems that are managed by, or on behalf of, the
      Licensor for the purpose of discussing and improving the Work, but
      excluding communication that is conspicuously marked or otherwise
      designated in writing by the copyright owner as "Not a Contribution."

      "Contributor" shall mean Licensor and any individual or Legal Entity
      on behalf of whom a Contribution has been received by Licensor and
      subsequently incorporated within the Work.

   2. Grant of Copyright License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      copyright license to reproduce, prepare Derivative Works of,
      publicly display, publicly perform, sublicense, and distribute the
      Work and such Derivative Works in Source or Object form.

   3. Grant of Patent License. Subject to the terms and conditions of
      this License, each Contributor hereby grants to You a perpetual,
      worldwide, non-exclusive, no-charge, royalty-free, irrevocable
      (except as stated in this section) patent license to make, have made,
      use, offer to sell, sell, import, and otherwise transfer the Work,
      where such license applies only to those patent claims licensable
      by such Contributor that are necessarily infringed by their
      Contribution(s) alone or by combination of their Contribution(s)
      with the Work to which such Contribution(s) was submitted. If You
      institute patent litigation against any entity (including a
      cross-claim or counterclaim in a lawsuit) alleging that the Work
      or a Contribution incorporated within the Work constitutes direct
      or contributory patent infringement, then any patent licenses
      granted to You under this License for that Work shall terminate
      as of the date such litigation is filed.

   4. Redistribution. You may reproduce and distribute copies of the
      Work or Derivative Works thereof in any medium, with or without
      modifications, and in Source or Object form, provided that You
      meet the following conditions:

      (a) You must give any other recipients of the Work or
          Derivative Works a copy of this License; and

      (b) You must cause any modified files to carry prominent notices
          stating that You changed the files; and

      (c) You must retain, in the Source form of any Derivative Works
          that You distribute, all copyright, patent, trademark, and
          attribution notices from the Source form of the Work,
          excluding those notices that do not pertain to any part of
          the Derivative Works; and

      (d) If the Work includes a "NOTICE" text file as part of its
          distribution, then any Derivative Works that You distribute must
          include a readable copy of the attribution notices contained
          within such NOTICE file, excluding those notices that do not
          pertain to any part of the Derivative Works, in at least one
          of the following places: within a NOTICE text file distributed
          as part of the Derivative Works; within the Source form or
          documentation, if provided along with the Derivative Works; or,
          within a display generated by the Derivative Works, if and
          wherever such third-party notices normally appear. The contents
          of the NOTICE file are for informational purposes only and
          do not modify the License. You may add Your own attribution
          notices within Derivative Works that You distribute, alongside
          or as an addendum to the NOTICE text from the Work, provided
          that such additional attribution notices cannot be construed
          as modifying the License.

      You may add Your own copyright statement to Your modifications and
      may provide additional or different license terms and conditions
      for use, reproduction, or distribution of Your modifications, or
      for any such Derivative Works as a whole, provided Your use,
      reproduction, and distribution of the Work otherwise complies with
      the conditions stated in this License.

   5. Submission of Contributions. Unless You explicitly state otherwise,
      any Contribution intentionally submitted for inclusion in the Work
      by You to the Licensor shall be under the terms and conditions of
      this License, without any additional terms or conditions.
      Notwithstanding the above, nothing herein shall supersede or modify
      the terms of any separate license agreement you may have executed
      with Licensor regarding such Contributions.

   6. Trademarks. This License does not grant permission to use the trade
      names, trademarks, service marks, or product names of the Licensor,
      except as required for reasonable and customary use in describing the
      origin of the Work and reproducing the content of the NOTICE file.

   7. Disclaimer of Warranty. Unless required by applicable law or
      agreed to in writing, Licensor provides the Work (and each
      Contributor provides its Contributions) on an "AS IS" BASIS,
      WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
      implied, including, without limitation, any warranties or conditions
      of TITLE, NON-INFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A
      PARTICULAR PURPOSE. You are solely responsible for determining the
      appropriateness of using or redistributing the Work and assume any
      risks associated with Your exercise of permissions under this License.

   8. Limitation of Liability. In no event and under no legal theory,
      whether in tort (including negligence), contract, or otherwise,
      unless required by applicable law (such as deliberate and grossly
      negligent acts) or agreed to in writing, shall any Contributor be
      liable to You for damages, including any direct, indirect, special,
      incidental, or consequential damages of any character arising as a
      result of this License or out of the use or inability to use the
      Work (including but not limited to damages for loss of goodwill,
      work stoppage, computer failure or malfunction, or any and all
      other commercial damages or losses), even if such Contributor
      has been advised of the possibility of such damages.

   9. Accepting Warranty or Additional Liability. While redistributing
      the Work or Derivative Works thereof, You may choose to offer,
      and charge a fee for, acceptance of support, warranty, indemnity,
      or other liability obligations and/or rights consistent with this
      License. However, in accepting such obligations, You may act only
      on Your own behalf and on Your sole responsibility, not on behalf
      of any other Contributor, and only if You agree to indemnify,
      defend, and hold each Contributor harmless for any liability
      incurred by, or claims asserted against, such Contributor by reason
      of your accepting any such warranty or additional liability.

% --------------------------------------------------------------------------- %

We are not aware of any particular licence terms for the following
files/functions/scripts/code snippets.

- "moving_average" by Matlab Central user 'Carlos Adrian Vargas Aguilera',
  retrieved from http://www.mathworks.com/matlabcentral/fileexchange/12276.
  We have modified the original code in our implementation.

- The "nansuite" package by Matlab Central user 'Jan Glaescher', retrieved from
  http://www.mathworks.com/matlabcentral/fileexchange/6837.  We have modified
  the original code in our implementation.

- "ReadImageJROI.m", by UZH member Dylan Muir

- Portions of the function "stack_slider", by StackOverflow user 'Benoit_11',
  retrieved from   http://stackoverflow.com/questions/28256106/image-stack-display-in-matlab-using-a-slider.
  We have modified the original code in our implementation.

- "scim_openTif.m" and "parseHeader.m", taken from ScanImage v3.8.1.  Refer to
  Pologruto TA, Sabatini BL, Svoboda K. ScanImage: Flexible software for
  operating laser scanning microscopes. BioMed Eng OnLine. 2003;2(1):1-9.
  We have modified the original code in our implementation.

% --------------------------------------------------------------------------- %

Although the code is not incorporated into CHIPS directly, and must be
downloaded separately, we are greatful to the authors of the following software
libraries and/or packages  for releasing or otherwise making versions of their
code available.

The CHIPS class BioFormats uses the Bio-Formats java library and MATLAB
functions, as described in the following paper:

- Linkert M, Rueden CT, Allan C, Burel J-M, Moore W, Patterson A, et al.
  Metadata matters: access to image data in the real world. The Journal of
  Cell Biology. 2010 May 31;189(5):777â€“82. The Bio-Formats Library is
  available from https://www.openmicroscopy.org/site/products/bio-formats.

The CHIPS function utils.denoise() calls a number of functions described in the
following papers:

- Azzari L, MÃ¤kitalo M, Foi A. Optimal inversion of the Anscombe and
  Generalized Anscombe variance-stabilizing transformations. Available from
  http://www.cs.tut.fi/~foi/invansc/.

- Maggioni M, SÃ¡nchez-Monge E, Foi A, Danielyan A, Dabov K, Katkovnik V,
  Egiazarian K. Image and video denoising by sparse 3D transform-domain
  collaborative filtering. Available from http://www.cs.tut.fi/~foi/GCF-BM3D/.

```

---
[Home](./index.html)
