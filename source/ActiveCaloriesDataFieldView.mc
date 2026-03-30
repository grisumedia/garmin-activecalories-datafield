import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;
using Toybox.Activity;

class ActiveCaloriesDataFieldView extends WatchUi.SimpleDataField {

    private var previousCalories = 0 as Number;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = WatchUi.loadResource(Rez.Strings.Label);
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        var activityInfo = Activity.getActivityInfo();
        var totalActivityCalories = activityInfo.calories;
        if (totalActivityCalories == null) {
            totalActivityCalories = 0;
        }

        var activityTimerMinutes = activityInfo.timerTime / 1000.0 / 60.0;

		var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);		
		var profile = UserProfile.getProfile();
		var age = today.year - profile.birthYear;
		var weight = profile.weight / 1000.0;

        var restCalories = 0.0;

		if (profile.gender == UserProfile.GENDER_MALE) {
			restCalories = 5.2 - 6.116 * age + 7.628 * profile.height + 12.2 * weight;
		} else {// female
			restCalories = -197.6 - 6.116 * age + 7.628 * profile.height + 12.2 * weight;
		}
		restCalories = Math.round(activityTimerMinutes * restCalories / 1440).toNumber();
		var activeCalories = totalActivityCalories - restCalories;

        // Prevent decreasing numbers when the resting calories increase
        if (previousCalories < activeCalories) {
            previousCalories = activeCalories;
            return activeCalories;
        }
        else {
            return previousCalories;
        }

    }

}