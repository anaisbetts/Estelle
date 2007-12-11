/***************************************************************************
    copyright            : (C) 2006 by Lukáš Lalinský
    email                : lalinsky@gmail.com
    
    copyright            : (C) 2004 by Allan Sandfeld Jensen
    email                : kde@carewolf.org
                           (original MPC implementation)
 ***************************************************************************/

/***************************************************************************
 *   This library is free software; you can redistribute it and/or modify  *
 *   it  under the terms of the GNU Lesser General Public License version  *
 *   2.1 as published by the Free Software Foundation.                     *
 *                                                                         *
 *   This library is distributed in the hope that it will be useful, but   *
 *   WITHOUT ANY WARRANTY; without even the implied warranty of            *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU     *
 *   Lesser General Public License for more details.                       *
 *                                                                         *
 *   You should have received a copy of the GNU Lesser General Public      *
 *   License along with this library; if not, write to the Free Software   *
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,            *
 *   MA  02110-1301  USA                                                   *
 ***************************************************************************/

#include <tstring.h>
#if 0
#include <tdebug.h>
#endif
#include <bitset>

#include "ttaproperties.h"
#include "ttafile.h"

using namespace TagLib;

class TTA::Properties::PropertiesPrivate
{
public:
  PropertiesPrivate(const ByteVector &d, long length, ReadStyle s) :
    data(d),
    streamLength(length),
    style(s),
    version(0),
    length(0),
    bitrate(0),
    sampleRate(0),
    channels(0),
    bitsPerSample(0) {}

  ByteVector data;
  long streamLength;
  ReadStyle style;
  int version;
  int length;
  int bitrate;
  int sampleRate;
  int channels;
  int bitsPerSample;
};

////////////////////////////////////////////////////////////////////////////////
// public members
////////////////////////////////////////////////////////////////////////////////

TTA::Properties::Properties(const ByteVector &data, long streamLength, ReadStyle style) : AudioProperties(style)
{
  d = new PropertiesPrivate(data, streamLength, style);
  read();
}

TTA::Properties::~Properties()
{
  delete d;
}

int TTA::Properties::length() const
{
  return d->length;
}

int TTA::Properties::bitrate() const
{
  return d->bitrate;
}

int TTA::Properties::sampleRate() const
{
  return d->sampleRate;
}

int TTA::Properties::bitsPerSample() const
{
  return d->bitsPerSample;
}

int TTA::Properties::channels() const
{
  return d->channels;
}

int TTA::Properties::ttaVersion() const
{
  return d->version;
}

////////////////////////////////////////////////////////////////////////////////
// private members
////////////////////////////////////////////////////////////////////////////////

void TTA::Properties::read()
{
  if(!d->data.startsWith("TTA"))
    return;

  int pos = 3;
  
  d->version = d->data[pos] - '0';
  pos += 1 + 2;

  d->channels = d->data.mid(pos, 2).toShort(false);
  pos += 2;
  
  d->bitsPerSample = d->data.mid(pos, 2).toShort(false);
  pos += 2;
  
  d->sampleRate = d->data.mid(pos, 4).toUInt(false);
  pos += 4;
  
  unsigned long samples = d->data.mid(pos, 4).toUInt(false);
  d->length = samples / d->sampleRate;
  
  d->bitrate = d->length > 0 ? ((d->streamLength * 8L) / d->length) / 1000 : 0;
}
