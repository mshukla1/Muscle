/*
A KBase module: Muscle
This module takes FeatureSet as input and runs Muscle to generate NA/AA MSA.
*/

module Muscle {
    /*
        A string representing a FeatureSet id.
    */
    /*typedef string featureset_id;*/

    /*
        A string representing a workspace name.
    */
    typedef string workspace_name;

    typedef structure {
        workspace_name workspace;
        string featureset_id;
        string feature_ids;
				string seq_type;
        string format;
    } MuscleParams;

    /* 
        The workspace ID for a FeatureSet data object.
        @id ws KBaseFeatures.FeatureSet
    */
    typedef string ws_featureset_id;

    typedef structure {
        ws_featureset_id featureset_ref;
        string program;
				int features;
        string output_file;
    } MuscleResults;
	
    /*
        Run Muscle on a FeatureSet
    */
    funcdef run_muscle(MuscleParams params) returns (MuscleResults) authentication required;
};
