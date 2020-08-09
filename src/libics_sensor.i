////////////////////////////////////////////////////////////////////////////////
// IcsEnableWriteSensor

%pythonappend IcsEnableWriteSensor (ICS *ics, int enable) {
    return raise_on_error(val)
}

Ics_Error IcsEnableWriteSensor (ICS *ics, int enable);
/* This function enables writing the sensor parameters to disk. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorType

char const *IcsGetSensorType (ICS const* ics);
/* Get the sensor type string. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorType

%pythonappend IcsSetSensorType (ICS *ics, char const *sensor_type) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorType (ICS *ics, char const *sensor_type);
/* Set the sensor type string. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorModel

char const *IcsGetSensorModel (ICS const *ics);
/* Get the sensor model string. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorModel

%pythonappend IcsSetSensorModel (ICS *ics, char const *sensor_model) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorModel (ICS *ics, char const *sensor_model);
/* Set the sensor model string. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorChannels

int IcsGetSensorChannels (ICS const *ics);
/* Get the number of sensor channels. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorChannels

%pythonappend IcsSetSensorChannels (ICS *ics, int channels) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorChannels (ICS *ics, int channels);
/* Set the number of sensor channels. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorPinholeRadius

double IcsGetSensorPinholeRadius (ICS const *ics, int channel);
/* Get the pinhole radius for a sensor channel. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorPinholeRadius

%pythonappend IcsSetSensorPinholeRadius (ICS *ics, int channel, double radius) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorPinholeRadius (ICS *ics, int channel, double radius);
/* Set the pinhole radius for a sensor channel. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorExcitationWavelength

double IcsGetSensorExcitationWavelength (ICS const *ics, int channel);
/* Get the excitation wavelength for a sensor channel. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorExcitationWavelength

%pythonappend IcsSetSensorExcitationWavelength (ICS *ics, int channel, double wl) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorExcitationWavelength (ICS *ics, int channel, double wl);
/* Set the excitation wavelength for a sensor channel. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorEmissionWavelength

double IcsGetSensorEmissionWavelength (ICS const *ics, int channel);
/* Get the emission wavelength for a sensor channel. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorEmissionWavelength

%pythonappend IcsSetSensorEmissionWavelength (ICS *ics, int channel, double wl) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorEmissionWavelength (ICS *ics, int channel, double wl);
/* Set the emission wavelength for a sensor channel. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorPhotonCount

int IcsGetSensorPhotonCount (ICS const *ics, int channel);
/* Get the excitation photon count for a sensor channel. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorPhotonCount

%pythonappend IcsSetSensorPhotonCount (ICS *ics, int channel, int cnt) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorPhotonCount (ICS *ics, int channel, int cnt);
/* Set the excitation photon count for a sensor channel. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorMediumRI

double IcsGetSensorMediumRI (ICS const *ics);
/* Get the sensor embedding medium refractive index. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorMediumRI

%pythonappend IcsSetSensorMediumRI (ICS *ics, double ri) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorMediumRI (ICS *ics, double ri);
/* Set the sensor embedding medium refractive index. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorLensRI

double IcsGetSensorLensRI (ICS const *ics);
/* Get the sensor design medium refractive index. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorLensRI

%pythonappend IcsSetSensorLensRI (ICS *ics, double ri) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorLensRI (ICS *ics, double ri);
/* Set the sensor design medium refractive index. */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorNumAperture

double IcsGetSensorNumAperture (ICS const *ics);
/* Get the sensor numerical apperture */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorNumAperture

%pythonappend IcsSetSensorNumAperture (ICS *ics, double na) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorNumAperture (ICS *ics, double na);
/* Set the sensor numerical apperture */

////////////////////////////////////////////////////////////////////////////////
// IcsGetSensorPinholeSpacing

double IcsGetSensorPinholeSpacing (ICS const *ics);
/* Get the sensor Nipkow Disk pinhole spacing. */

////////////////////////////////////////////////////////////////////////////////
// IcsSetSensorPinholeSpacing

%pythonappend IcsSetSensorPinholeSpacing (ICS *ics, double spacing) {
    return raise_on_error(val)
}

Ics_Error IcsSetSensorPinholeSpacing (ICS *ics, double spacing);
/* Set the sensor Nipkow Disk pinhole spacing. */
