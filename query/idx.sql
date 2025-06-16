USE internships_application_tracker;


CREATE INDEX idx_applications_user_date ON applications(user_id, application_date);
CREATE INDEX idx_applications_status ON applications(status_id);
CREATE INDEX idx_positions_company ON positions(company_id);
CREATE INDEX idx_interviews_application ON interviews(application_id, interview_date);
CREATE INDEX idx_notes_application_date ON notes(application_id, creation_date);
CREATE INDEX idx_contacts_company ON contacts(company_id);

