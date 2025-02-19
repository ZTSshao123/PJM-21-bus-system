function corrected_zone_ID = correct_zone_ID(zone_ID)
    % This function corrects zone_ID based on recent changes on the PJM website.
    % MECK's ID (14) is changed to DOM's ID (13) to reflect the merger into the DOM region.
    % If the zone_ID is 14, it's changed to 13.
    % If the zone_ID is greater than 14, it is decreased by 1 to adjust for renumbering of zones.
    
    if zone_ID == 14
        corrected_zone_ID = 13;  % Change MECK ID (14) to DOM ID (13)
    elseif zone_ID > 14
        corrected_zone_ID = zone_ID - 1;  % Decrease zone_ID by 1 for IDs greater than 14
    else
        corrected_zone_ID = zone_ID;  % Keep zone_ID the same if it is less than 14
    end
end
